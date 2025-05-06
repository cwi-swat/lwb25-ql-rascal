module Check

import Message;
import IO;
import ParseTree;
import List;

extend Syntax;

syntax Type = "*unknown*";

alias TEnv = lrel[str, Type];

// build a Type Environment (TEnv) for a questionnaire.
TEnv collect(Form f) = [ <"<q.name>", q.\type> | /Question q := f, q has prompt ];


/*
 * typeOf: compute the type of expressions
 */

// the fall back type is *unknown*
default Type typeOf(Expr _, TEnv env) = (Type)`*unknown*`;

Type typeOf((Expr)`<Id x>`, TEnv env) = t
    when <"<x>", Type t> <- env;

Type typeOf((Expr)`(<Expr e>)`, TEnv env) = typeOf(e, env);

Type typeOf((Expr)`<Int _>`, TEnv env) = (Type)`integer`;

Type typeOf((Expr)`<Bool _>`, TEnv env) = (Type)`boolean`;

Type typeOf((Expr)`<Str _>`, TEnv env) = (Type)`string`;

Type typeOf((Expr)`<Expr _> * <Expr _>`, TEnv env) = (Type)`integer`;
Type typeOf((Expr)`<Expr _> / <Expr _>`, TEnv env) = (Type)`integer`;
Type typeOf((Expr)`<Expr _> + <Expr _>`, TEnv env) = (Type)`integer`;
Type typeOf((Expr)`<Expr _> - <Expr _>`, TEnv env) = (Type)`integer`;

Type typeOf((Expr)`<Expr _> \< <Expr _>`, TEnv env) = (Type)`boolean`;
Type typeOf((Expr)`<Expr _> \> <Expr _>`, TEnv env) = (Type)`boolean`;
Type typeOf((Expr)`<Expr _> \>= <Expr _>`, TEnv env) = (Type)`boolean`;
Type typeOf((Expr)`<Expr _> \<= <Expr _>`, TEnv env) = (Type)`boolean`;
Type typeOf((Expr)`<Expr _> == <Expr _>`, TEnv env) = (Type)`boolean`;
Type typeOf((Expr)`<Expr _> != <Expr _>`, TEnv env) = (Type)`boolean`;
Type typeOf((Expr)`<Expr _> && <Expr _>`, TEnv env) = (Type)`boolean`;
Type typeOf((Expr)`<Expr _> || <Expr _>`, TEnv env) = (Type)`boolean`;

/*
 * Checking forms
 */

set[Message] check(start[Form] form) = check(form.top);

set[Message] check(Form form) 
  = { *check(q, env) | Question q <- form.questions }
  + checkDuplicates(form)
  + checkCycles(form)
  when TEnv env := collect(form);

set[Message] checkCycles(Form form) {
    rel[str, str, loc] dataDeps = { <"<x>", "<y>", q.src> 
        | /q:(Question)`<Str _> <Id x>: <Type _> = <Expr e>` := form, /Id y := e };

    rel[str, str, loc] controlDeps 
        = { <"<q2.name>", "<x>", q2.src> | /(Question)`if (<Expr cond>) <Question q>` := form,
            /Id x := cond, /Question q2 := q, q2 has name }
        + { <"<q2.name>", "<x>", q2.src> | /(Question)`if (<Expr cond>) <Question q> else <Question q1>` := form,
            /Id x := cond, /Question q2 := (Question)`{<Question q> <Question q1>}` , q2 has name };

    set[Message] msgs = {};
    
    for (<str x, x> <- dataDeps<0,1>+, <_, x, loc a> <- dataDeps) {
        msgs += {error("cyclic data dependency", a)};
    }

    for (<str x, x> <- controlDeps<0,1>+, <_, x, loc a> <- controlDeps) {
        msgs += {error("cyclic control dependency", a)};
    }

    return msgs;
}

set[Message] checkDuplicates(Form form) {
    set[Message] msgs = {};
    set[Question] seen = {};
    top-down visit (form) {
        case Question q: {
            if (q has prompt) {
                Type t = q.\type;
                if (Question q0 <- seen, "<q0.name>" == "<q.name>") {
                    msgs += {error("redeclared with different type", q.src) | t !:= q0.\type };
                    msgs += {warning("redeclared with different prompt", q.src) | "<q.prompt>" != "<q0.prompt>"};
                }
                if (Question q0 <- seen, "<q0.name>" != "<q.name>", "<q0.prompt>" == "<q.prompt>") {
                    msgs += {warning("different question with same prompt", q.src)};
                }
                seen += {q};
                msgs += { warning("empty prompt", q.src) | (Str)`""` := q.prompt };
            }
        }
    }
    return msgs;
}

/*
 * Checking questions
 */

// by default, there are no errors
default set[Message] check(Question _, TEnv _) = {};

set[Message] check((Question)`<Str p> <Id x>: <Type t> = <Expr e>`, TEnv env)
    = { error("incompatible type", e.src) | t !:= typeOf(e, env) }
    + check(e, env);

set[Message] ifThenIssues(Expr cond, Question then, TEnv env)
    = { error("expected boolean", cond.src) | (Type)`boolean` !:= typeOf(cond, env) }
    + { warning("empty then-branch", then.src) | (Question)`{}` := then }
    + { warning("useless condition", cond.src) | (Expr)`true` := cond }
    + { warning("dead then-branch", then.src) | (Expr)`false` := cond }
    + check(cond, env) + check(then, env);


set[Message] check((Question)`if (<Expr cond>) <Question then>`, TEnv env)
    = ifThenIssues(cond, then, env);

set[Message] check((Question)`if (<Expr cond>) <Question then> else <Question els>`, TEnv env)
    = ifThenIssues(cond, then, env)
    + { warning("empty else-branch", els.src) | (Question)`{}` := els }
    + check(els, env);


set[Message] check((Question)`{<Question* qs>}`, TEnv env)
    = { *check(q, env) | Question q <- qs };


/*
 * Checking expressions
 */


// when the other cases fail, there are no errors
default set[Message] check(Expr _, TEnv env) = {};

set[Message] check(e:(Expr)`<Id x>`, TEnv env) = {error("undefined question", x.src)}
    when "<x>" notin env<0>;

set[Message] check((Expr)`(<Expr e>)`, TEnv env) = check(e, env);


set[Message] checkArith(Expr x, Expr y, TEnv env)
    = { error("invalid operand", x.src) | (Type)`integer` !:= typeOf(x, env) }
    + { error("invalid operand", y.src) | (Type)`integer` !:= typeOf(y, env) }
    + check(x, env) + check(y, env);

set[Message] check(e:(Expr)`<Expr x> * <Expr y>`, TEnv env) = checkArith(x, y, env);

set[Message] check(e:(Expr)`<Expr x> / <Expr y>`, TEnv env) = checkArith(x, y, env);

set[Message] check((Expr)`<Expr x> + <Expr y>`, TEnv env) = checkArith(x, y, env);

set[Message] check(e:(Expr)`<Expr x> - <Expr y>`, TEnv env) = checkArith(x, y, env);

set[Message] check((Expr)`<Expr x> \< <Expr y>`, TEnv env) = checkArith(x, y, env);

set[Message] check((Expr)`<Expr x> \> <Expr y>`, TEnv env) = checkArith(x, y, env);

set[Message] check((Expr)`<Expr x> \<= <Expr y>`, TEnv env) = checkArith(x, y, env);

set[Message] check((Expr)`<Expr x> \>= <Expr y>`, TEnv env) = checkArith(x, y, env);

set[Message] checkEqNeq(Expr e, Expr x, Expr y, TEnv env)
    = { error("incompatible operand types", e.src) | Type t := typeOf(x, env), t !:= typeOf(y, env) }
    + check(x, env) + check(y, env);

set[Message] check(e:(Expr)`<Expr x> == <Expr y>`, TEnv env) = checkEqNeq(e, x, y, env);

set[Message] check(e:(Expr)`<Expr x> != <Expr y>`, TEnv env) = checkEqNeq(e, x, y, env);

set[Message] checkLogic(Expr x, Expr y, TEnv env) 
    = { error("invalid operand", x.src) | (Type)`boolean` !:= typeOf(x, env) }
    + { error("invalid operand", y.src) | (Type)`boolean` !:= typeOf(y, env) }
    + check(x, env) + check(y, env);

set[Message] check(e:(Expr)`<Expr x> && <Expr y>`, TEnv env) = checkLogic(x, y, env);

set[Message] check(e:(Expr)`<Expr x> || <Expr y>`, TEnv env) = checkLogic(x, y, env);

module Resolve

import Syntax;
import ParseTree;

alias Def = rel[str name, loc def];
alias Use = rel[loc use, str name];
alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[Use uses, Def defs, UseDef useDef]; 

RefGraph resolve(start[Form] f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(start[Form] f) = { <x.src, "<x>"> | /(Expr)`<Id x>` := f };

Def defs(start[Form] f) = { <"<q.name>", q.name.src> | /Question q := f, q has prompt };

module IDE

/*
 * Import this module in a Rascal terminal and execute `main()`
 * to enable language services in the IDE.
 */

import util::LanguageServer;
import util::Reflective;
import util::IDEServices;
import IO;
import ValueIO;
import List;

import Syntax;
import Compile;
import Check;
import Resolve;
import Message;
import ParseTree;

void main() {
    registerLanguage(
        language(
            pathConfig(srcs = [|std:///|, |project://lwb25-ql-rascal/src|]),
            "QL", "myql", "IDE", "myLanguageContributor"));
}


set[LanguageService] myLanguageContributor() = {
    parser(Tree (str input, loc src) {
        return parse(#start[Form], input, src);
    }),
    lenses(myLenses),
    outliner(myOutliner),
    executor(myCommands),
    summarizer(mySummarizer, providesDocumentation = false, providesDefinitions = true
        , providesReferences = false, providesImplementations = false)
};


data Command = compileQuestionnaire(start[Form] form);

Summary mySummarizer(loc origin, start[Form] input) 
  = summary(origin, messages = {<m.at, m> | Message m <- check(input) }
      , definitions=resolve(input).useDef);


rel[loc,Command] myLenses(start[Form] input) 
  = {<input.src, compileQuestionnaire(input, title="Compile")>};
     
list[DocumentSymbol] myOutliner(start[Form] input) 
  = [symbol("<input.top.title>"[1..-1], \module(), input.src,
        children=[ symbol("<q.name>: <q.\type>", \class(), q.src) 
          | /Question q := input, q has prompt ]) ];
        


void myCommands(compileQuestionnaire(start[Form] form)) = compile(form);




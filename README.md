## A minimal but complete implementation of QL in Rascal

How to use:
- Install [VS Code](https://code.visualstudio.com/)
- Install the [Rascal](https://www.rascal-mpl.org/docs/GettingStarted/DownloadAndInstallation/) extension from the Market place
- Clone this repository [https://github.com/cwi-swat/lwb25-ql-rascal](https://github.com/cwi-swat/lwb25-ql-rascal)
- Add the folder `lwb25-ql-rascal` to your VS Code workspace (don't rename the folder).
- Open `src/IDE.rsc` and click on the link above the `main` function.

Now, the IDE for QL is enabled, and you can open the example questionnaires in `examples`.

Code overview:
- `Syntax.rsc`: grammar for QL
- `Resolve.rsc`: name resolution
- `Check.rsc`: type checking and cyclic dependency checking
- `Compile.rsc`: compilation to HTML and Javascript
- `IDE.rsc`: IDE wiring

IDE Features:
- Syntax highlighting
- Jump-to-definition
- Hover documentation
- Error marking
- Compile button
- Code folding
- Outline

Type checker features:

Errors
- reference to undefined question
- duplicate question declaration with different type
- conditional expression not of boolean type 
- operands of invalid type to operators
- computed expression not conforming to declared type.

Warnings
- empty prompts
- empty if-then-else branches
- useless conditions
- dead then branches
- redeclared with different prompt
- cyclic data and control dependencies

Total source lines of code (SLOC): 352.

## QL: a DSL for Questionnaires

A QL program consists of a form, containing questions. A question can be a normal question, that expects an answer (i.e. is answerable), or a computed question. A computed question has an associated expression which defines its value. 

Both kinds of questions have a prompt (to show to the user), an identifier (its name), and a type. The language supports boolean, integer and string types.

Questions can be conditional and the conditional construct comes in two variants: **if** and **if-else**. A block construct using `{}` can be used to group questions.

Questions are enabled and disabled when different values are entered, depending on their conditional context.

Here’s a simple questionnaire in QL from the domain of tax filing:
```
form "Tax office example" { 
  "Did you sell a house in 2010?" // the prompt of the question
    hasSoldHouse: boolean         // and its name and type
  "Did you buy a house in 2010?"
    hasBoughtHouse: boolean
  "Did you enter a loan?"
    hasMaintLoan: boolean
    
  if (hasSoldHouse) { // conditional block
    "What was the selling price?"
      sellingPrice: integer
    "Private debts for the sold house:"
      privateDebt: integer
    "Value residue:"
      valueResidue: integer =      // a computed question
        sellingPrice - privateDebt // has an expression 
  }
}
```

A full type checker of QL detects:
- references to undefined questions
- duplicate question declarations with different types
- conditions that are not of the type boolean
- operands of invalid type to operators
- duplicate labels (warning)
- cyclic data and control dependencies

Different data types in QL map to different (default) GUI widgets. For instance, boolean would be represented as checkboxes, integers as text fields with numeric sliders, and strings as text fields. 

See the folder `examples/` for example QL programs. Opening a QL file will show a link at the top for compiling a QL program. Type errors are marked with squiglies in the IDE. 
Compiling will result in an HTML file and a Javascript file; opening
the HTML file in a browser will execute the questionnaire.



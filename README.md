## A minimal but complete implementation of QL in Rascal

Author: [Tijs van der Storm](mailto:storm@cwi.nl), CWI.

For the original description of QL see the [task description of the language workbench competition 2013](https://github.com/judithmichael/lwb25/blob/main/ChallengeTask.pdf)

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
- operands of invalid type to operator
- computed expression not conforming to declared type.
- cyclic data and control dependencies

Warnings
- empty prompt
- empty then/else-branch
- useless condition
- dead then-branch
- redeclared with different prompt

**Total source lines of code (SLOC): 352.**


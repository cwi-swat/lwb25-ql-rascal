## TinyQL: A minimal but complete implementation of QL in Rascal

**Total source lines of code (SLOC): 352.**

Author: [Tijs van der Storm](mailto:storm@cwi.nl), CWI.

For the original description of QL see the [task description of the language workbench competition 2013](https://github.com/judithmichael/lwb25/blob/main/ChallengeTask.pdf)

How to use:
- Install [VS Code](https://code.visualstudio.com/)
- Install the [Rascal](https://www.rascal-mpl.org/docs/GettingStarted/DownloadAndInstallation/) extension from the Market place
- Clone this repository [https://github.com/cwi-swat/tiny-ql](https://github.com/cwi-swat/tiny-ql)
- Add the folder `tiny-ql` to your VS Code workspace (don't rename the folder).
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



// =====================================================================
// MATH 2210 Applied Linear Algebra — Chapters 1–3
// True/False flashcards — compatible with the french-quiz format
//
// Extracted official questions:
//   Chapter 1: 10
//   Chapter 2: 23
//   Chapter 3: 20
// Added bonus questions:
//   Chapters 1 & 2: 8
//   Chapters 2 & 3: 8
//   Total cards: 69
// =====================================================================

window.ETAPE_DATA = {
vocab: [
// =================================================================
// CHAPTER 1
// =================================================================


// Section 1-2 — Exercise 6
// Part (a)
{
  en:"If every variable is basic, then the linear system has exactly one solution.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"This is true provided that there is some solution to the linear system. We have to avoid the situation when there are infinitely many solutions, and this happens only when there is a free variable.",
  category:"chapter1"
},

// Part (b)
{
  en:"If two augmented matrices are row equivalent to one another, then they describe two linear systems having the same solution spaces.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"This is true. When two matrices are row equivalent, there is a sequence of scaling, interchange, and replacement operations that transforms one matrix into the other. These operations do not change the solution space of the matrix.",
  category:"chapter1"
},

// Part (c)
{
  en:"The presence of a free variable indicates that there are no solutions to the linear system.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"This is false. A free variable means the system has infinitely many solutions when the system is consistent. A free variable does not itself make the system inconsistent.",
  category:"chapter1"
},

// Part (d)
{
  en:"If a linear system has exactly one solution, then it must have the same number of equations as variables.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A system may have more equations than variables and still have exactly one solution. Some equations may be redundant.",
  category:"chapter1"
},

// Part (e)
{
  en:"If a linear system has the same number of equations as variables, then it has exactly one solution.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Having the same number of equations and variables does not guarantee a pivot in every variable column. The system could have no solution or infinitely many solutions.",
  category:"chapter1"
},

// Section 1-4 — Exercise 4
// Part (a)
{
  en:"If the coefficient matrix of a linear system has a pivot in the rightmost column, then the system is inconsistent.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The coefficient matrix does not include the augmented column. It is a pivot in the rightmost column of the augmented matrix that produces a contradiction and makes the system inconsistent.",
  category:"chapter1"
},

// Part (b)
{
  en:"If a linear system has two equations and four variables, then it must be consistent.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The augmented matrix could contain a contradiction row such as [0 0 0 0 | 1]. Therefore, the system could be inconsistent.",
  category:"chapter1"
},

// Part (c)
{
  en:"If a linear system having four equations and three variables is consistent, then the solution is unique.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A consistent system can still have a free variable. If there is a free variable, the system has infinitely many solutions rather than a unique solution.",
  category:"chapter1"
},

// Part (d)
{
  en:"Suppose that a linear system has four equations and four variables and that the coefficient matrix has four pivots. Then the linear system is consistent and has a unique solution.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Four pivots in a 4x4 coefficient matrix means there is a pivot in every row and every variable column. Therefore, there is no contradiction and there are no free variables.",
  category:"chapter1"
},

// Part (e)
{
  en:"Suppose that a linear system has five equations and three variables and that the coefficient matrix has a pivot position in every column. Then the linear system is consistent and has a unique solution.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A pivot in every coefficient column eliminates free variables, but the augmented matrix may still contain a pivot in its last column. That would make the system inconsistent.",
  category:"chapter1"
},

// =================================================================
// CHAPTER 2
// =================================================================

// Section 2-1 — Exercise 7
// Part (a)
{
  en:"Given two vectors \\(\\mathbf{v}\\) and \\(\\mathbf{w}\\), the vector \\(2\\mathbf{v}\\) is a linear combination of \\(\\mathbf{v}\\) and \\(\\mathbf{w}\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Choose the weights 2 and 0. Then \\(2\\mathbf{v}+0\\mathbf{w}=2\\mathbf{v}\\).",
  category:"chapter2"
},

// Part (b)
{
  en:"Suppose \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\) is a collection of \\(m\\)-dimensional vectors and the matrix whose columns are these vectors has a pivot position in every row. If \\(\\mathbf{b}\\) is any \\(m\\)-dimensional vector, then \\(\\mathbf{b}\\) can be written as a linear combination of the vectors.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A pivot in every row means the columns span \\(\\mathbb{R}^m\\). Therefore, every vector \\(\\mathbf{b}\\) in \\(\\mathbb{R}^m\\) is a linear combination of the columns.",
  category:"chapter2"
},

// Part (c)
{
  en:"Suppose \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\) is a collection of \\(m\\)-dimensional vectors and the matrix whose columns are these vectors has a pivot position in every row and every column. If \\(\\mathbf{b}\\) is any \\(m\\)-dimensional vector, then \\(\\mathbf{b}\\) can be written as a linear combination of the vectors in exactly one way.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A pivot in every row guarantees existence for every \\(\\mathbf{b}\\). A pivot in every column guarantees there are no free variables, so the representation is unique.",
  category:"chapter2"
},

// Part (d)
{
  en:"It is possible to find two 3-dimensional vectors \\(\\mathbf{v}_1\\) and \\(\\mathbf{v}_2\\) such that every 3-dimensional vector can be written as a linear combination of \\(\\mathbf{v}_1\\) and \\(\\mathbf{v}_2\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Two vectors can span at most a plane through the origin in \\(\\mathbb{R}^3\\). At least three appropriately chosen vectors are needed to span all of \\(\\mathbb{R}^3\\).",
  category:"chapter2"
},

// Section 2-2 — Exercise 9
// Part (a)
{
  en:"If \\(A\\mathbf{x}\\) is defined, then the number of components of \\(\\mathbf{x}\\) equals the number of rows of \\(A\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The number of components of \\(\\mathbf{x}\\) must equal the number of columns of \\(A\\).",
  category:"chapter2"
},

// Part (b)
{
  en:"The solution space to the equation \\(A\\mathbf{x}=\\mathbf{b}\\) is equivalent to the solution space of the linear system whose augmented matrix is \\([A|\\mathbf{b}]\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The matrix equation and the corresponding augmented matrix describe exactly the same system of equations.",
  category:"chapter2"
},

// Part (c)
{
  en:"If a linear system has 8 equations and 5 unknowns, then the shape of the matrix \\(A\\) in \\(A\\mathbf{x}=\\mathbf{b}\\) is \\(5\\times8\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Each equation gives one row and each unknown gives one column. Therefore, \\(A\\) is an \\(8\\times5\\) matrix.",
  category:"chapter2"
},

// Part (d)
{
  en:"If \\(A\\) has a pivot position in every row, then every equation \\(A\\mathbf{x}=\\mathbf{b}\\) is consistent.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A pivot in every row means the columns of \\(A\\) span the entire codomain. Therefore, every possible vector \\(\\mathbf{b}\\) can be produced.",
  category:"chapter2"
},

// Part (e)
{
  en:"If \\(A\\) is a \\(9\\times5\\) matrix, then \\(A\\mathbf{x}=\\mathbf{b}\\) is inconsistent for some vector \\(\\mathbf{b}\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A 9x5 matrix can have at most 5 pivots, so it cannot have a pivot in every one of its 9 rows. Its columns cannot span all of \\(\\mathbb{R}^9\\), so some vectors \\(\\mathbf{b}\\) are not reachable.",
  category:"chapter2"
},

// Section 2-3 — Exercise 5
// Part (a)
{
  en:"If the equation \\(A\\mathbf{x}=\\mathbf{b}\\) is consistent, then \\(\\mathbf{b}\\) is in the span of the columns of \\(A\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A solution \\(\\mathbf{x}\\) provides weights that combine the columns of \\(A\\) to produce \\(\\mathbf{b}\\).",
  category:"chapter2"
},

// Part (b)
{
  en:"If \\(\\mathbf{v}_1\\) is the first column of \\(A\\), then the equation \\(A\\mathbf{x}=\\mathbf{v}_1\\) is consistent.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Choose \\(\\mathbf{x}=[1,0,\\ldots,0]^T\\). This selects the first column of \\(A\\), producing \\(\\mathbf{v}_1\\).",
  category:"chapter2"
},

// Part (c)
{
  en:"If \\(\\mathbf{v}_1\\), \\(\\mathbf{v}_2\\), \\(\\mathbf{v}_3\\), and \\(\\mathbf{v}_4\\) are vectors in \\(\\mathbb{R}^3\\), then their span is \\(\\mathbb{R}^3\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The vectors might all lie on the same line or plane. Having four vectors does not guarantee that they span all of \\(\\mathbb{R}^3\\).",
  category:"chapter2"
},

// Part (d)
{
  en:"If \\(\\mathbf{b}\\) is a linear combination of \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\), then \\(\\mathbf{b}\\) is in \\(\\operatorname{span}\\{\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\}\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The span is defined as the set of every possible linear combination of the given vectors.",
  category:"chapter2"
},

// Part (e)
{
  en:"If \\(A\\) is an \\(8032\\times427\\) matrix, then the span of the columns of \\(A\\) is a set of vectors in \\(\\mathbb{R}^{427}\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Each column has 8032 components. Therefore, the columns and their linear combinations belong to \\(\\mathbb{R}^{8032}\\).",
  category:"chapter2"
},

// Section 2-4 — Exercise 4
// Part (a)
{
  en:"If \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\) are linearly dependent, then one vector is a scalar multiple of one of the others.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Linear dependence guarantees that one vector can be written as a linear combination of the others. It does not have to be a scalar multiple of only one other vector.",
  category:"chapter2"
},

// Part (b)
{
  en:"If \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_{10}\\) are vectors in \\(\\mathbb{R}^5\\), then the set of vectors is linearly dependent.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"There are more vectors than dimensions. A set containing more than 5 vectors in \\(\\mathbb{R}^5\\) must be linearly dependent.",
  category:"chapter2"
},

// Part (c)
{
  en:"If \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_5\\) are vectors in \\(\\mathbb{R}^{10}\\), then the set of vectors is linearly independent.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Five vectors in \\(\\mathbb{R}^{10}\\) could be independent, but they could also be dependent. Their actual entries or pivot positions must be examined.",
  category:"chapter2"
},

// Part (d)
{
  en:"Suppose \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\) is a set of vectors and \\(\\mathbf{v}_2\\) is a scalar multiple of \\(\\mathbf{v}_1\\). Then the set is linearly dependent.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"One vector can be written as a multiple of another, producing a nontrivial linear combination equal to the zero vector.",
  category:"chapter2"
},

// Part (e)
{
  en:"Suppose that \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\) are linearly independent and form the columns of a matrix \\(A\\). If \\(A\\mathbf{x}=\\mathbf{b}\\) is consistent, then there is exactly one solution.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Linear independence means there is a pivot in every column, so there are no free variables. Since the system is consistent, its solution is unique.",
  category:"chapter2"
},

// Section 2-5 — Exercise 6
// Part (a)
{
  en:"A matrix transformation \\(T:\\mathbb{R}^4\\to\\mathbb{R}^5\\) is defined by \\(T(\\mathbf{x})=A\\mathbf{x}\\), where \\(A\\) is a \\(4\\times5\\) matrix.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The domain dimension determines the number of columns and the codomain dimension determines the number of rows. Therefore, \\(A\\) must be \\(5\\times4\\).",
  category:"chapter2"
},

// Part (b)
{
  en:"If \\(T:\\mathbb{R}^3\\to\\mathbb{R}^2\\) is a matrix transformation, then there are infinitely many vectors \\(\\mathbf{x}\\) such that \\(T(\\mathbf{x})=\\mathbf{0}\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The standard matrix is 2x3, so it has more columns than rows. It must have at least one free variable, giving infinitely many solutions to the homogeneous equation.",
  category:"chapter2"
},

// Part (c)
{
  en:"If \\(T:\\mathbb{R}^2\\to\\mathbb{R}^3\\) is a matrix transformation, then it is possible that every equation \\(T(\\mathbf{x})=\\mathbf{b}\\) has a solution for every vector \\(\\mathbf{b}\\in\\mathbb{R}^3\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The standard matrix is 3x2 and can have at most two pivots. It cannot have a pivot in every one of its three rows, so it cannot map onto all of \\(\\mathbb{R}^3\\).",
  category:"chapter2"
},

// Part (d)
{
  en:"If \\(T:\\mathbb{R}^n\\to\\mathbb{R}^m\\) is a matrix transformation, then the equation \\(T(\\mathbf{x})=\\mathbf{0}\\) always has a solution.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Every matrix transformation maps the zero vector to the zero vector. Therefore, \\(\\mathbf{x}=\\mathbf{0}\\) is always a solution.",
  category:"chapter2"
},

// =================================================================
// CHAPTER 3
// =================================================================

// Section 3-1 — Exercise 7
// Part (a)
{
  en:"If \\(A\\) is invertible, then the columns of \\(A\\) are linearly independent.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"An invertible matrix has a pivot in every column. Therefore, \\(A\\mathbf{x}=\\mathbf{0}\\) has only the trivial solution and the columns are linearly independent.",
  category:"chapter3"
},

// Part (b)
{
  en:"If \\(A\\) is a square matrix whose diagonal entries are all nonzero, then \\(A\\) is invertible.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Nonzero diagonal entries guarantee invertibility only for a triangular matrix. For example, [[1,1],[1,1]] has nonzero diagonal entries but is not invertible.",
  category:"chapter3"
},

// Part (c)
{
  en:"If \\(A\\) is an invertible \\(n\\times n\\) matrix, then the span of the columns of \\(A\\) is \\(\\mathbb{R}^n\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"An invertible matrix has a pivot in every row, so its columns span \\(\\mathbb{R}^n\\).",
  category:"chapter3"
},

// Part (d)
{
  en:"If \\(A\\) is invertible, then there is a nonzero solution to the homogeneous equation \\(A\\mathbf{x}=\\mathbf{0}\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"An invertible matrix has a pivot in every column, so the homogeneous equation has only the zero solution.",
  category:"chapter3"
},

// Part (e)
{
  en:"If \\(A\\) is an \\(n\\times n\\) matrix and the equation \\(A\\mathbf{x}=\\mathbf{b}\\) has a solution for every vector \\(\\mathbf{b}\\), then \\(A\\) is invertible.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Having a solution for every \\(\\mathbf{b}\\) means the columns span \\(\\mathbb{R}^n\\), so there is a pivot in every row. Since the matrix is square, it also has a pivot in every column and is invertible.",
  category:"chapter3"
},

// Section 3-2 — Exercise 6
// Part (a)
{
  en:"If the columns of a matrix \\(A\\) form a basis for \\(\\mathbb{R}^m\\), then \\(A\\) is invertible.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A basis of \\(\\mathbb{R}^m\\) contains exactly \\(m\\) vectors, so \\(A\\) is square. The columns are independent and span \\(\\mathbb{R}^m\\), making \\(A\\) invertible.",
  category:"chapter3"
},

// Part (b)
{
  en:"There must be 125 vectors in a basis for \\(\\mathbb{R}^{125}\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Every basis of an n-dimensional vector space contains exactly n vectors.",
  category:"chapter3"
},

// Part (c)
{
  en:"If \\(\\mathcal{B}=\\{\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\}\\) is a basis of \\(\\mathbb{R}^m\\), then every vector in \\(\\mathbb{R}^m\\) can be expressed as a linear combination of the basis vectors.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A basis spans the entire vector space. Therefore, every vector in the space can be written as a linear combination of the basis vectors.",
  category:"chapter3"
},

// Part (d)
{
  en:"The coordinates \\([\\mathbf{x}]_{\\mathcal{B}}\\) are the weights that form \\(\\mathbf{x}\\) as a linear combination of the basis vectors.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The coordinate vector records the unique coefficients used to express \\(\\mathbf{x}\\) as a linear combination of the basis vectors.",
  category:"chapter3"
},

// Part (e)
{
  en:"If the basis vectors form the columns of the matrix \\(P_{\\mathcal{B}}\\), then \\([\\mathbf{x}]_{\\mathcal{B}}=P_{\\mathcal{B}}\\mathbf{x}\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The correct relationship is \\(\\mathbf{x}=P_{\\mathcal{B}}[\\mathbf{x}]_{\\mathcal{B}}\\). Equivalently, \\([\\mathbf{x}]_{\\mathcal{B}}=P_{\\mathcal{B}}^{-1}\\mathbf{x}\\) when the inverse exists.",
  category:"chapter3"
},

// Section 3-4 — Exercise 5
// Part (a)
{
  en:"If we have a square matrix \\(A\\) and multiply the first row by 5 and add it to the third row to obtain \\(A'\\), then \\(\\det(A')=5\\det(A)\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Adding a multiple of one row to another row is a row replacement operation. A row replacement does not change the determinant.",
  category:"chapter3"
},

// Part (b)
{
  en:"If we interchange two rows of a matrix, then the determinant is unchanged.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Interchanging two rows changes the sign of the determinant.",
  category:"chapter3"
},

// Part (c)
{
  en:"If we scale a row of the matrix \\(A\\) by 17 to obtain \\(A'\\), then \\(\\det(A')=17\\det(A)\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Multiplying one row by a scalar multiplies the determinant by that same scalar.",
  category:"chapter3"
},

// Part (d)
{
  en:"If \\(A\\) and \\(A'\\) are row equivalent and \\(\\det(A')=0\\), then \\(\\det(A)=0\\) also.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Elementary row operations multiply the determinant by a nonzero factor or change its sign. They cannot change a zero determinant into a nonzero determinant.",
  category:"chapter3"
},

// Part (e)
{
  en:"If \\(A\\) is row equivalent to the identity matrix, then \\(\\det(A)=\\det(I)=1\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Row equivalence to the identity shows that \\(A\\) is invertible and that \\(\\det(A)\\neq0\\). Row swaps and row scalings may have changed the determinant, so it does not have to equal 1.",
  category:"chapter3"
},

// Section 3-5 — Exercise 3
// Part (a)
{
  en:"If \\(A\\) is a \\(127\\times341\\) matrix, then \\(\\operatorname{nul}(A)\\) is a subspace of \\(\\mathbb{R}^{127}\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The vectors \\(\\mathbf{x}\\) in the equation \\(A\\mathbf{x}=\\mathbf{0}\\) have 341 components. Therefore, \\(\\operatorname{nul}(A)\\) is a subspace of \\(\\mathbb{R}^{341}\\).",
  category:"chapter3"
},

// Part (b)
{
  en:"If \\(\\dim(\\operatorname{nul}(A))=0\\), then the columns of \\(A\\) are linearly independent.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Nullity zero means the homogeneous equation has only the zero solution. That is exactly the condition for the columns of \\(A\\) to be linearly independent.",
  category:"chapter3"
},

// Part (c)
{
  en:"If \\(\\operatorname{col}(A)=\\mathbb{R}^m\\), then \\(A\\) is invertible.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The condition means that the columns span \\(\\mathbb{R}^m\\), but \\(A\\) may not be square. Only square matrices can be invertible.",
  category:"chapter3"
},

// Part (d)
{
  en:"If \\(A\\) has a pivot position in every column, then \\(\\operatorname{nul}(A)=\\mathbb{R}^n\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A pivot in every column means there are no free variables. Therefore, the null space contains only the zero vector.",
  category:"chapter3"
},

// Part (e)
{
  en:"If \\(\\operatorname{col}(A)=\\mathbb{R}^m\\) and \\(\\operatorname{nul}(A)=\\{\\mathbf{0}\\}\\), then \\(A\\) is invertible.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The column-space condition gives a pivot in every row. The null-space condition gives a pivot in every column. Therefore, the number of rows equals the number of columns and \\(A\\) is invertible.",
  category:"chapter3"
},

// =================================================================
// BONUS — CHAPTERS 1 & 2
// =================================================================

{
  en:"If \\(\\mathbf{b}\\) is in the span of the columns of \\(A\\), then \\(A\\mathbf{x}=\\mathbf{b}\\) is consistent.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Being in the span means that some linear combination of the columns equals \\(\\mathbf{b}\\). The coefficients of that combination form a solution \\(\\mathbf{x}\\).",
  category:"bonus12"
},

{
  en:"If the homogeneous equation \\(A\\mathbf{x}=\\mathbf{0}\\) has a free variable, then the columns of \\(A\\) are linearly dependent.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A free variable gives a nonzero solution to the homogeneous equation. This creates a nontrivial linear combination of the columns equal to zero.",
  category:"bonus12"
},

{
  en:"If the augmented matrix \\([A|\\mathbf{b}]\\) has a pivot in its last column, then \\(\\mathbf{b}\\) is not in the span of the columns of \\(A\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A pivot in the augmented column creates a contradiction, so the equation is inconsistent. Therefore, \\(\\mathbf{b}\\) is not a linear combination of the columns.",
  category:"bonus12"
},

{
  en:"If \\(A\\) has more columns than rows, then the columns of \\(A\\) are linearly dependent.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"There cannot be a pivot in every column when there are more columns than rows. At least one free variable exists in \\(A\\mathbf{x}=\\mathbf{0}\\), so the columns are dependent.",
  category:"bonus12"
},

{
  en:"Row-equivalent matrices always have the same column space.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Row operations preserve the solution set of the homogeneous equation, but they can change the actual columns and their column space.",
  category:"bonus12"
},

{
  en:"If \\(A\\mathbf{x}=\\mathbf{b}\\) is consistent and the columns of \\(A\\) are linearly independent, then the solution is unique.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Independent columns mean there is a pivot in every column and no free variables. Since a solution exists, it must be the only solution.",
  category:"bonus12"
},

{
  en:"If \\(A\\mathbf{x}=\\mathbf{b}\\) is inconsistent, then \\(\\mathbf{b}\\) is not a linear combination of the columns of \\(A\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"The equation is consistent exactly when \\(\\mathbf{b}\\) belongs to the span of the columns of \\(A\\).",
  category:"bonus12"
},

{
  en:"If the columns of \\(A\\) are linearly dependent, then \\(A\\mathbf{x}=\\mathbf{b}\\) has infinitely many solutions for every vector \\(\\mathbf{b}\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Dependent columns mean that every consistent equation has infinitely many solutions. However, some vectors \\(\\mathbf{b}\\) may make the equation inconsistent.",
  category:"bonus12"
},

// =================================================================
// BONUS — CHAPTERS 2 & 3
// =================================================================

{
  en:"An \\(n\\times n\\) matrix \\(A\\) is invertible if and only if its columns form a basis for \\(\\mathbb{R}^n\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Invertibility is equivalent to having a pivot in every row and column. Therefore, the columns are linearly independent and span \\(\\mathbb{R}^n\\).",
  category:"bonus23"
},

{
  en:"For an \\(n\\times n\\) matrix \\(A\\), \\(\\det(A)\\neq0\\) if and only if \\(A\\mathbf{x}=\\mathbf{0}\\) has only the zero solution.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A nonzero determinant is equivalent to invertibility. An invertible matrix has a pivot in every column, so its homogeneous equation has only the zero solution.",
  category:"bonus23"
},

{
  en:"If \\(A\\) is invertible, then the matrix transformation \\(T(\\mathbf{x})=A\\mathbf{x}\\) is both one-to-one and onto.",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A pivot in every column makes the transformation one-to-one. A pivot in every row makes it onto.",
  category:"bonus23"
},

{
  en:"If \\(A\\) is row equivalent to the identity matrix \\(I\\), then \\(\\det(A)=1\\).",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"Row equivalence to \\(I\\) proves only that the determinant is nonzero. Row swaps and row scalings may change its actual value.",
  category:"bonus23"
},

{
  en:"If \\(\\operatorname{nul}(A)=\\{\\mathbf{0}\\}\\), then \\(A\\) must be invertible.",
  fr:"False",
  alts:["False","false"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A trivial null space means the columns are independent. A nonsquare matrix can have independent columns but cannot be invertible.",
  category:"bonus23"
},

{
  en:"If the columns of \\(A\\) form a basis for \\(\\mathbb{R}^m\\), then \\(A\\) is square and \\(\\det(A)\\neq0\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A basis of \\(\\mathbb{R}^m\\) has exactly m vectors. Since each column has m entries, \\(A\\) is m by m and its basis columns make it invertible.",
  category:"bonus23"
},

{
  en:"If \\(\\det(A)=0\\) for an \\(n\\times n\\) matrix, then the columns of \\(A\\) cannot form a basis for \\(\\mathbb{R}^n\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"A zero determinant means the matrix is not invertible. Therefore, its columns do not satisfy both basis requirements.",
  category:"bonus23"
},

{
  en:"If \\(A\\) is an invertible \\(n\\times n\\) matrix, then \\(\\dim(\\operatorname{col}(A))=n\\) and \\(\\dim(\\operatorname{nul}(A))=0\\).",
  fr:"True",
  alts:["True","true"],
  needsHyphen:false,
  needsAccent:false,
  gender:"both",
  guessGender:true,
  explanation:"An invertible matrix has rank n, so its column space has dimension n. Rank-nullity then gives a nullity of zero.",
  category:"bonus23"
}


],

categoryLabels: {
all:"All Topics",
chapter1:"Chapter 1",
chapter2:"Chapter 2",
chapter3:"Chapter 3",
bonus12:"Bonus — Chapters 1 & 2",
bonus23:"Bonus — Chapters 2 & 3"
}
};

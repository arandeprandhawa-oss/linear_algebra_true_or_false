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
    {en:"If every variable is basic, then the linear system has exactly one solution.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This is true provided that there is some solution to the linear system. We have to avoid the situation when there are infinitely many solutions, and this happens only when there is a free variable.", category:"chapter1"},
    // Part (b)
    {en:"If two augmented matrices are row equivalent to one another, then they describe two linear systems having the same solution spaces.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This is true. When two matrices are row equivalent, there is a sequence of scaling, interchange, and replacement operations that transforms one matrix into the other. These operations do not change the solution space of the matrix.", category:"chapter1"},
    // Part (c)
    {en:"The presence of a free variable indicates that there are no solutions to the linear system.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This is false. The presence of a free variable tells us there are infinitely many solutions.", category:"chapter1"},
    // Part (d)
    {en:"If a linear system has exactly one solution, then it must have the same number of equations as variables.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This is false. The reduced row echelon form of the augmented matrix could look like \\[\\left[\\begin{array}{rr|r} 1 & 0 & -3 \\\\ 0 & 1 & 4 \\\\ 0 & 0 & 0 \\\\ \\end{array}\\right]\\text{.}\\] In this case, there are three equations in two variables, and the system has exactly one solution.", category:"chapter1"},
    // Part (e)
    {en:"If a linear system has the same number of equations as variables, then it has exactly one solution.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This is false, and here is a reduced row echelon matrix that illustrates why. \\[\\left[\\begin{array}{rr|r} 1 & 2 & -1 \\\\ 0 & 0 & 0 \\\\ \\end{array}\\right]\\text{.}\\]", category:"chapter1"},
    // Section 1-4 — Exercise 4
    // Part (a)
    {en:"If the coefficient matrix of a linear system has a pivot in the rightmost column, then the system is inconsistent.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This statement is false. If the augmented matrix has a pivot in the rightmost column, then the system is inconsistent.", category:"chapter1"},
    // Part (b)
    {en:"If a linear system has two equations and four variables, then it must be consistent.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This statement is false as illustrated by the matrix \\[\\left[\\begin{array}{rrrr|r} 1 & 0 & 2 & 3 & -1 \\\\ 0 & 0 & 0 & 0 & 1\\\\ \\end{array}\\right]\\text{.}\\]", category:"chapter1"},
    // Part (c)
    {en:"If a linear system having four equations and three variables is consistent, then the solution is unique.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This statement is false as illustrated by the matrix \\[\\left[\\begin{array}{rrr|r} 1 & 0 & 2 & 1 \\\\ 0 & 1 & -2 & 0 \\\\ 0 & 0 & 0 & 0 \\\\ 0 & 0 & 0 & 0\\\\ \\end{array}\\right]\\text{.}\\]", category:"chapter1"},
    // Part (d)
    {en:"Suppose that a linear system has four equations and four variables and that the coefficient matrix has four pivots. Then the linear system is consistent and has a unique solution.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This statement is true as illustrated by the matrix \\[\\left[\\begin{array}{rrrr|r} 1 & 0 & 0 & 0 & 1 \\\\ 0 & 1 & 0 & 0 & 3\\\\ 0 & 0 & 1 & 0 & -1 \\\\ 0 & 0 & 0 & 1 & 7\\\\ \\end{array}\\right]\\text{.}\\]", category:"chapter1"},
    // Part (e)
    {en:"Suppose that a linear system has five equations and three variables and that the coefficient matrix has a pivot position in every column. Then the linear system is consistent and has a unique solution.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. A pivot in every coefficient column eliminates free variables, but the augmented matrix may still contain a pivot in its last column, which would make the system inconsistent.", category:"chapter1"},

    // =================================================================
    // CHAPTER 2
    // =================================================================
    // Section 2-1 — Exercise 7
    // Part (a)
    {en:"Given two vectors \\(\\mathbf{v}\\) and \\(\\mathbf{w}\\), the vector \\(2\\mathbf{v}\\) is a linear combination of \\(\\mathbf{v}\\) and \\(\\mathbf{w}\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True, because we can choose the weights \\(c=2\\) and \\(d=0\\).", category:"chapter2"},
    // Part (b)
    {en:"Suppose \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\) is a collection of \\(m\\)-dimensional vectors and that the matrix \\(\\left[\\begin{array}{rrrr} \\mathbf{v}_1 & \\mathbf{v}_2 & \\ldots & \\mathbf{v}_n \\end{array}\\right]\\) has a pivot position in every row. If \\(\\mathbf{b}\\) is any \\(m\\)-dimensional vector, then \\(\\mathbf{b}\\) can be written as a linear combination of \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True, because the augmented matrix \\(\\left[\\begin{array}{rrrr|r} \\mathbf{v}_1 & \\mathbf{v}_2 & \\ldots & \\mathbf{v}_n & \\mathbf{b} \\end{array}\\right]\\) can never have a pivot position in the rightmost column.", category:"chapter2"},
    // Part (c)
    {en:"Suppose \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\) is a collection of \\(m\\)-dimensional vectors and that the matrix \\(\\left[\\begin{array}{rrrr} \\mathbf{v}_1 & \\mathbf{v}_2 & \\ldots & \\mathbf{v}_n \\end{array}\\right]\\) has a pivot position in every row and every column. If \\(\\mathbf{b}\\) is any \\(m\\)-dimensional vector, then \\(\\mathbf{b}\\) can be written as a linear combination of \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\) in exactly one way.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True, because the augmented matrix \\(\\left[\\begin{array}{rrrr|r} \\mathbf{v}_1 & \\mathbf{v}_2 & \\ldots & \\mathbf{v}_n & \\mathbf{b} \\end{array}\\right]\\) can never have a pivot position in the rightmost column and the corresponding linear system cannot have a free variable.", category:"chapter2"},
    // Part (d)
    {en:"It is possible to find two 3-dimensional vectors \\(\\mathbf{v}_1\\) and \\(\\mathbf{v}_2\\) such that every 3-dimensional vector can be written as a linear combination of \\(\\mathbf{v}_1\\) and \\(\\mathbf{v}_2\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False, because it is possible to choose a vector \\(\\mathbf{b}\\) such that the augmented matrix \\(\\left[\\begin{array}{rr|r} \\mathbf{v}_1 & \\mathbf{v}_2 & \\mathbf{b} \\end{array}\\right]\\) has a pivot in the rightmost column.", category:"chapter2"},
    // Section 2-2 — Exercise 9
    // Part (a)
    {en:"If \\(A\\mathbf{x}\\) is defined, then the number of components of \\(\\mathbf{x}\\) equals the number of rows of \\(A\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False, the number of components of \\(\\mathbf{x}\\) equals the number of columns of \\(A\\).", category:"chapter2"},
    // Part (b)
    {en:"The solution space to the equation \\(A\\mathbf{x} = \\mathbf{b}\\) is equivalent to the solution space to the linear system whose augmented matrix is \\(\\left[\\begin{array}{r|r} A & \\mathbf{b} \\end{array}\\right]\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. The matrix equation \\(A\\mathbf{x}=\\mathbf{b}\\) and the linear system with augmented matrix \\(\\left[\\begin{array}{r|r}A&\\mathbf{b}\\end{array}\\right]\\) represent the same equations, so they have the same solution set.", category:"chapter2"},
    // Part (c)
    {en:"If a linear system of equations has 8 equations and 5 unknowns, then the shape of the matrix \\(A\\) in the corresponding equation \\(A\\mathbf{x} = \\mathbf{b}\\) is \\(5\\times8\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. The shape of \\(A\\) is \\(8\\times5\\).", category:"chapter2"},
    // Part (d)
    {en:"If \\(A\\) has a pivot position in every row, then every equation \\(A\\mathbf{x} = \\mathbf{b}\\) is consistent.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True, because the augmented matrix \\(\\left[\\begin{array}{r|r} A & \\mathbf{b} \\end{array}\\right]\\) cannot have a pivot position in the rightmost column.", category:"chapter2"},
    // Part (e)
    {en:"If \\(A\\) is a \\(9\\times5\\) matrix, then \\(A\\mathbf{x}=\\mathbf{b}\\) is inconsistent for some vector \\(\\mathbf{b}\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. Because there is not a pivot position in every row of \\(A\\), the augmented matrix \\(\\left[\\begin{array}{r|r} A & \\mathbf{b} \\end{array}\\right]\\) will have a pivot position in the rightmost column for some vectors \\(\\mathbf{b}\\).", category:"chapter2"},
    // Section 2-3 — Exercise 5
    // Part (a)
    {en:"If the equation \\(A\\mathbf{x} = \\mathbf{b}\\) is consistent, then \\(\\mathbf{b}\\) is in \\(\\operatorname{span}\\left\\{\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\right\\}\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. If \\(\\mathbf{x}\\) is a solution to \\(A\\mathbf{x}=\\mathbf{b}\\), then the components of \\(\\mathbf{x}\\) are weights whose linear combination is \\(\\mathbf{b}\\).", category:"chapter2"},
    // Part (b)
    {en:"The equation \\(A\\mathbf{x} = \\mathbf{v}_1\\) is consistent.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True, because \\(x=\\begin{bmatrix}1\\\\0\\\\\\vdots\\\\0\\end{bmatrix}\\) is a solution.", category:"chapter2"},
    // Part (c)
    {en:"If \\(\\mathbf{v}_1\\), \\(\\mathbf{v}_2\\), \\(\\mathbf{v}_3\\), and \\(\\mathbf{v}_4\\) are vectors in \\(\\mathbb{R}^3\\), then their span is \\(\\mathbb{R}^3\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. The span could be a smaller set.", category:"chapter2"},
    // Part (d)
    {en:"If \\(\\mathbf{b}\\) is a linear combination of \\(\\mathbf{v}_1, \\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\), then \\(\\mathbf{b}\\) is in \\(\\operatorname{span}\\left\\{\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\right\\}\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. This is the definition of the span.", category:"chapter2"},
    // Part (e)
    {en:"If \\(A\\) is an \\(8032\\times 427\\) matrix, then the span of the columns of \\(A\\) is a set of vectors in \\(\\mathbb{R}^{427}\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. The span is a set of vectors in \\(\\mathbb{R}^{8032}\\).", category:"chapter2"},
    // Section 2-4 — Exercise 4
    // Part (a)
    {en:"If \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\) are linearly dependent, then one vector is a scalar multiple of one of the others.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. We only know that one vector can be written as a linear combination of the others.", category:"chapter2"},
    // Part (b)
    {en:"If \\(\\mathbf{v}_1, \\mathbf{v}_2, \\ldots, \\mathbf{v}_{10}\\) are vectors in \\(\\mathbb{R}^5\\), then the set of vectors is linearly dependent.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. If we put the vectors into a matrix, there are more columns than rows. Therefore, there must be a column without a pivot position so the vectors form a linearly dependent set.", category:"chapter2"},
    // Part (c)
    {en:"If \\(\\mathbf{v}_1, \\mathbf{v}_2, \\ldots, \\mathbf{v}_{5}\\) are vectors in \\(\\mathbb{R}^{10}\\), then the set of vectors is linearly independent.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. They could form a linearly independent set, but we cannot guarantee it. We would have to look at the location of the pivot positions in the associated \\(10\\times5\\) matrix.", category:"chapter2"},
    // Part (d)
    {en:"Suppose we have a set of vectors \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\) and that \\(\\mathbf{v}_2\\) is a scalar multiple of \\(\\mathbf{v}_1\\). Then the set is linearly dependent.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. In this case, \\(\\mathbf{v}_2\\) can be written as a linear combination of the other vectors so the set is linearly dependent.", category:"chapter2"},
    // Part (e)
    {en:"Suppose that \\(\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\) are linearly independent and form the columns of a matrix \\(A\\). If \\(A\\mathbf{x} = \\mathbf{b}\\) is consistent, then there is exactly one solution.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. Since the vectors are linearly independent, \\(A\\) has a pivot position in every column. Therefore, there is not a free variable in the description of the solution space to the equation \\(A\\mathbf{x}=\\mathbf{b}\\). Therefore, the solution is unique.", category:"chapter2"},
    // Section 2-5 — Exercise 6
    // Part (a)
    {en:"A matrix transformation \\(T:\\mathbb{R}^4\\to\\mathbb{R}^5\\) is defined by \\(T(\\mathbf{x}) = A\\mathbf{x}\\) where \\(A\\) is a \\(4\\times5\\) matrix.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. The dimensions of \\(A\\) are \\(5\\times4\\).", category:"chapter2"},
    // Part (b)
    {en:"If \\(T:\\mathbb{R}^3\\to\\mathbb{R}^2\\) is a matrix transformation, then there are infinitely many vectors \\(\\mathbf{x}\\) such that \\(T(\\mathbf{x}) = \\mathbf{0}\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. The dimensions of \\(A\\) are \\(2\\times3\\) so there must be a column without a pivot position.", category:"chapter2"},
    // Part (c)
    {en:"If \\(T:\\mathbb{R}^2\\to\\mathbb{R}^3\\) is a matrix transformation, then it is possible that every equation \\(T(\\mathbf{x}) = \\mathbf{b}\\) has a solution for every vector \\(\\mathbf{b}\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. The dimensions of \\(A\\) are \\(3\\times2\\) so there must be a row without a pivot position.", category:"chapter2"},
    // Part (d)
    {en:"If \\(T:\\mathbb{R}^n\\to\\mathbb{R}^m\\) is a matrix transformation, then the equation \\(T(\\mathbf{x}) = \\mathbf{0}\\) always has a solution.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. The vector \\(\\mathbf{x}=\\mathbf{0}\\) is always a solution.", category:"chapter2"},

    // =================================================================
    // CHAPTER 3
    // =================================================================
    // Section 3-1 — Exercise 7
    // Part (a)
    {en:"If \\(A\\) is invertible, then the columns of \\(A\\) are linearly independent.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. If \\(A\\) is invertible, then it has a pivot position in every column, which implies that the columns are linearly independent.", category:"chapter3"},
    // Part (b)
    {en:"If \\(A\\) is a square matrix whose diagonal entries are all nonzero, then \\(A\\) is invertible.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. We only know this if \\(A\\) is a triangular matrix. For instance, the matrix \\(\\left[\\begin{array}{rr} 1 & 1 \\\\ 1 & 1 \\\\ \\end{array}\\right]\\) is not invertible.", category:"chapter3"},
    // Part (c)
    {en:"If \\(A\\) is an invertible \\(n\\times n\\) matrix, then span of the columns of \\(A\\) is \\(\\mathbb{R}^n\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. If \\(A\\) is invertible, then it has a pivot position in every row, which implies that the columns span \\(\\mathbb{R}^n\\).", category:"chapter3"},
    // Part (d)
    {en:"If \\(A\\) is invertible, then there is a nonzero solution to the homogeneous equation \\(A\\mathbf{x} = \\mathbf{0}\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. Since there is a pivot position in every column, the homogeneous equation \\(A\\mathbf{x}=\\mathbf{0}\\) has only the zero solution \\(\\mathbf{x}=\\mathbf{0}\\).", category:"chapter3"},
    // Part (e)
    {en:"If \\(A\\) is an \\(n\\times n\\) matrix and the equation \\(A\\mathbf{x} = \\mathbf{b}\\) has a solution for every vector \\(\\mathbf{b}\\), then \\(A\\) is invertible.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. In this case, the columns of \\(A\\) span \\(\\mathbb{R}^n\\) so there must be a pivot position in every row. Because \\(A\\) is a square matrix, it must be row equivalent to the identity matrix \\(I\\).", category:"chapter3"},
    // Section 3-2 — Exercise 6
    // Part (a)
    {en:"If the columns of a matrix \\(A\\) form a basis for \\(\\mathbb{R}^m\\), then \\(A\\) is invertible.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. If the columns of \\(A\\) form a basis, then \\(A\\) has a pivot position in every row and every column. Therefore, the reduced row echelon form of \\(A\\) is the identity matrix, which implies that \\(A\\) is invertible.", category:"chapter3"},
    // Part (b)
    {en:"There must be 125 vectors in a basis for \\(\\mathbb{R}^{125}\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. The number of vectors in a basis of \\(\\mathbb{R}^m\\) must be \\(m\\).", category:"chapter3"},
    // Part (c)
    {en:"If \\(\\mathcal{B}=\\{\\mathbf{v}_1,\\mathbf{v}_2,\\ldots,\\mathbf{v}_n\\}\\) is a basis of \\(\\mathbb{R}^m\\), then every vector in \\(\\mathbb{R}^m\\) can be expressed as a linear combination of basis vectors.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. If \\(\\mathcal{B}\\) is a basis, then the vectors in \\(\\mathcal{B}\\) span \\(\\mathbb{R}^m\\), which means that every vector in \\(\\mathbb{R}^m\\) can be written as a linear combination of the vectors in \\(\\mathcal{B}\\).", category:"chapter3"},
    // Part (d)
    {en:"The coordinates \\([\\mathbf{x}]_{\\mathcal{B}}\\) are the weights that form \\(\\mathbf{x}\\) as a linear combination of basis vectors.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. This is the definition of \\([\\mathbf{x}]_{\\mathcal{B}}\\).", category:"chapter3"},
    // Part (e)
    {en:"If the basis vectors form the columns of the matrix \\(P_{\\mathcal{B}}\\), then \\([\\mathbf{x}]_{\\mathcal{B}} = P_{\\mathcal{B}}\\mathbf{x}\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. The relationship is \\(\\mathbf{x}=P_{\\mathcal{B}}[\\mathbf{x}]_{\\mathcal{B}}\\).", category:"chapter3"},
    // Section 3-4 — Exercise 5
    // Part (a)
    {en:"If we have a square matrix \\(A\\) and multiply the first row by \\(5\\) and add it to the third row to obtain \\(A'\\), then \\(\\operatorname{det}(A') = 5\\operatorname{det}(A)\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. This is a row replacement operation, which leaves the determinant unchanged.", category:"chapter3"},
    // Part (b)
    {en:"If we interchange two rows of a matrix, then the determinant is unchanged.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. Applying an interchange operation changes the sign of the determinant.", category:"chapter3"},
    // Part (c)
    {en:"If we scale a row of the matrix \\(A\\) by \\(17\\) to obtain \\(A'\\), then \\(\\operatorname{det}(A') = 17\\operatorname{det}(A)\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. Scaling a row of \\(A\\) by \\(r\\) multiplies the determinant by \\(r\\).", category:"chapter3"},
    // Part (d)
    {en:"If \\(A\\) and \\(A'\\) are row equivalent and \\(\\operatorname{det}(A') = 0\\), then \\(\\operatorname{det}(A) = 0\\) also.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. Row operations either leave the determinant unchanged, change its sign, or multiply it by a nonzero number. Therefore, if \\(\\operatorname{det}(A')=0\\) and \\(A\\) and \\(A'\\) are related through a sequence of row operations, then \\(\\operatorname{det}(A) = 0\\).", category:"chapter3"},
    // Part (e)
    {en:"If \\(A\\) is row equivalent to the identity matrix, then \\(\\operatorname{det}(A) = \\operatorname{det}(I) = 1\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. It is true that \\(\\operatorname{det}(I) = 1\\), but a sequence of row operations that cause \\(A\\) and \\(I\\) to be row equivalent may multiply the determinant by a nonzero number or change its sign. We do know, however, that \\(\\operatorname{det}(A)\\neq 0\\) and so \\(A\\) is invertible.", category:"chapter3"},
    // Section 3-5 — Exercise 3
    // Part (a)
    {en:"If \\(A\\) is a \\(127\\times 341\\) matrix, then \\(\\operatorname{nul}(A)\\) is a subspace of \\(\\mathbb{R}^{127}\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. \\(\\operatorname{nul}(A)\\) is a subspace of \\(\\mathbb{R}^{341}\\).", category:"chapter3"},
    // Part (b)
    {en:"If \\(\\operatorname{dim}~\\operatorname{nul}(A) = 0\\), then the columns of \\(A\\) are linearly independent.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. In this case, the only solution to the homogeneous equation \\(A\\mathbf{x}=\\mathbf{0}\\) is the zero solution \\(\\mathbf{x}=\\mathbf{0}\\). This means that every column has a pivot position so the columns are linearly independent.", category:"chapter3"},
    // Part (c)
    {en:"If \\(\\operatorname{col}(A) = \\mathbb{R}^m\\), then \\(A\\) is invertible.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. The matrix \\(A\\) is not necessarily a square matrix.", category:"chapter3"},
    // Part (d)
    {en:"If \\(A\\) has a pivot position in every column, then \\(\\operatorname{nul}(A) = \\mathbb{R}^n\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"False. If \\(A\\) has a pivot position in every column, then \\(\\operatorname{nul}(A) = \\{\\mathbf{0}\\}\\).", category:"chapter3"},
    // Part (e)
    {en:"If \\(\\operatorname{col}(A) = \\mathbb{R}^m\\) and \\(\\operatorname{nul}(A) = \\{\\mathbf{0}\\}\\), then \\(A\\) is invertible.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"True. Since \\(\\operatorname{col}(A)=\\mathbb{R}^m\\), we know that \\(A\\) has a pivot position in every row. Since \\(\\operatorname{nul}(A)=\\{\\mathbf{0}\\}\\), we know that \\(A\\) has a pivot position in every column. Therefore, \\(A\\) must be a square matrix and invertible.", category:"chapter3"},

    // =================================================================
    // BONUS — CHAPTERS 1 & 2
    // Original cross-chapter review questions
    // =================================================================
    {en:"If \\(\\mathbf{b}\\) is in the span of the columns of \\(A\\), then \\(A\\mathbf{x}=\\mathbf{b}\\) is consistent.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Being in the span of the columns means exactly that some linear combination of those columns equals \\(\\mathbf{b}\\). The coefficients of that combination form a solution \\(\\mathbf{x}\\).", category:"bonus12"},
    {en:"If the homogeneous equation \\(A\\mathbf{x}=\\mathbf{0}\\) has a free variable, then the columns of \\(A\\) are linearly dependent.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"A free variable gives a nonzero solution to \\(A\\mathbf{x}=\\mathbf{0}\\). A nonzero solution supplies a nontrivial linear combination of the columns equal to \\(\\mathbf{0}\\), so the columns are dependent.", category:"bonus12"},
    {en:"If the augmented matrix \\(\\left[\\begin{array}{r|r}A&\\mathbf{b}\\end{array}\\right]\\) has a pivot in its last column, then \\(\\mathbf{b}\\) is not in the span of the columns of \\(A\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"A pivot in the augmented column creates a contradiction, so \\(A\\mathbf{x}=\\mathbf{b}\\) is inconsistent. Therefore, \\(\\mathbf{b}\\) cannot be a linear combination of the columns of \\(A\\).", category:"bonus12"},
    {en:"If \\(A\\) has more columns than rows, then the columns of \\(A\\) are linearly dependent.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"There can be at most one pivot per row. With more columns than rows, at least one column has no pivot, so \\(A\\mathbf{x}=\\mathbf{0}\\) has a free variable and a nonzero solution.", category:"bonus12"},
    {en:"Row-equivalent matrices always have the same column space.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Row operations preserve the solution set of \\(A\\mathbf{x}=\\mathbf{0}\\), but they can change the actual columns and therefore change the column space.", category:"bonus12"},
    {en:"If \\(A\\mathbf{x}=\\mathbf{b}\\) is consistent and the columns of \\(A\\) are linearly independent, then the solution is unique.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Linear independence means there is a pivot in every column, so there are no free variables. Since the system is consistent, its solution must be unique.", category:"bonus12"},
    {en:"If \\(A\\mathbf{x}=\\mathbf{b}\\) is inconsistent, then \\(\\mathbf{b}\\) is not a linear combination of the columns of \\(A\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The equation is consistent exactly when \\(\\mathbf{b}\\) belongs to the span of the columns of \\(A\\).", category:"bonus12"},
    {en:"If the columns of \\(A\\) are linearly dependent, then \\(A\\mathbf{x}=\\mathbf{b}\\) has infinitely many solutions for every vector \\(\\mathbf{b}\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Dependence guarantees a nonzero solution to \\(A\\mathbf{x}=\\mathbf{0}\\). Thus any consistent equation has infinitely many solutions, but some choices of \\(\\mathbf{b}\\) may make the equation inconsistent.", category:"bonus12"},

    // =================================================================
    // BONUS — CHAPTERS 2 & 3
    // Original cross-chapter review questions
    // =================================================================
    {en:"An \\(n\\times n\\) matrix \\(A\\) is invertible if and only if its columns form a basis for \\(\\mathbb{R}^n\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Invertibility is equivalent to having a pivot in every row and every column. That means the columns both span \\(\\mathbb{R}^n\\) and are linearly independent.", category:"bonus23"},
    {en:"For an \\(n\\times n\\) matrix \\(A\\), \\(\\operatorname{det}(A)\\neq0\\) if and only if \\(A\\mathbf{x}=\\mathbf{0}\\) has only the zero solution.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"A nonzero determinant is equivalent to invertibility. An invertible matrix has a pivot in every column, so its null space is \\(\\{\\mathbf{0}\\}\\), and the converse also holds for a square matrix.", category:"bonus23"},
    {en:"If \\(A\\) is invertible, then the matrix transformation \\(T(\\mathbf{x})=A\\mathbf{x}\\) is both one-to-one and onto.", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"An invertible square matrix has a pivot in every column, making \\(T\\) one-to-one, and a pivot in every row, making \\(T\\) onto.", category:"bonus23"},
    {en:"If \\(A\\) is row equivalent to the identity matrix \\(I\\), then \\(\\operatorname{det}(A)=1\\).", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Row equivalence to \\(I\\) proves only that \\(\\operatorname{det}(A)\\neq0\\). Row swaps and row scalings may change the determinant before the matrix reaches \\(I\\).", category:"bonus23"},
    {en:"If \\(\\operatorname{nul}(A)=\\{\\mathbf{0}\\}\\), then \\(A\\) must be invertible.", fr:"False", alts:["False", "false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"A trivial null space means the columns are linearly independent, but a nonsquare matrix can have independent columns without being invertible.", category:"bonus23"},
    {en:"If the columns of \\(A\\) form a basis for \\(\\mathbb{R}^m\\), then \\(A\\) is square and \\(\\operatorname{det}(A)\\neq0\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"A basis for \\(\\mathbb{R}^m\\) contains exactly \\(m\\) vectors. Since each column has \\(m\\) entries, \\(A\\) is \\(m\\times m\\), and a square matrix with basis columns is invertible, so its determinant is nonzero.", category:"bonus23"},
    {en:"If \\(\\operatorname{det}(A)=0\\) for an \\(n\\times n\\) matrix, then the columns of \\(A\\) cannot form a basis for \\(\\mathbb{R}^n\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"A zero determinant means \\(A\\) is not invertible. Its columns therefore fail to be linearly independent, fail to span \\(\\mathbb{R}^n\\), or both.", category:"bonus23"},
    {en:"If \\(A\\) is an invertible \\(n\\times n\\) matrix, then \\(\\dim(\\operatorname{col}(A))=n\\) and \\(\\dim(\\operatorname{nul}(A))=0\\).", fr:"True", alts:["True", "true"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"An invertible matrix has rank \\(n\\), so its column space has dimension \\(n\\). Rank-nullity then gives nullity \\(n-n=0\\).", category:"bonus23"},
  ],
  categoryLabels: {
    all:"All Topics",
    chapter1:"Chapter 1",
    chapter2:"Chapter 2",
    chapter3:"Chapter 3",
    bonus12:"Bonus — Chapters 1 & 2",
    bonus23:"Bonus — Chapters 2 & 3",
  }
};

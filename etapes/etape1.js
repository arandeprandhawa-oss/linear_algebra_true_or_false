// =====================================================================
// MATH 2210 Applied Linear Algebra — True / False card bank
// Categories: systems, span, independence, matrices, inverses, lu,
//             determinants, transformations, subspaces, eigenvalues, markov
// =====================================================================

window.ETAPE_DATA = {
  vocab: [

    // ===== LINEAR SYSTEMS & ROW REDUCTION =====
    {en:"A homogeneous system Ax = 0 can be inconsistent.", fr:"False", alts:["False","false"], explanation:"Ax = 0 always has the trivial solution x = 0, so it is always consistent.", category:"systems"},
    {en:"If an augmented matrix [A|b] has a pivot in the last column, the system is inconsistent.", fr:"True", alts:["True","true"], explanation:"A pivot in the augmented column creates a contradiction row [0 … 0 | c] with c ≠ 0.", category:"systems"},
    {en:"Every matrix has a unique reduced row echelon form (RREF).", fr:"True", alts:["True","true"], explanation:"The RREF of any matrix is unique, even though the row operations used to reach it may differ.", category:"systems"},
    {en:"A consistent system with no free variables has exactly one solution.", fr:"True", alts:["True","true"], explanation:"No free variables means every variable is a pivot variable, so the solution is uniquely determined.", category:"systems"},
    {en:"A 3×5 system can have a unique solution.", fr:"False", alts:["False","false"], explanation:"A 3×5 matrix has at most 3 pivot columns, leaving at least 2 free variables. A consistent system must then have infinitely many solutions.", category:"systems"},
    {en:"If a linear system has more unknowns than equations, it must have infinitely many solutions.", fr:"False", alts:["False","false"], explanation:"It could also be inconsistent. 'More unknowns than equations' rules out a unique solution, but not all solutions.", category:"systems"},
    {en:"Row operations can change the column space of a matrix.", fr:"True", alts:["True","true"], explanation:"Row operations preserve the row space and null space, but they change the actual column vectors — so Col(A) can change. The pivot column positions stay the same, but not the columns themselves.", category:"systems"},
    {en:"Two row-equivalent matrices always have the same solution set for Ax = 0.", fr:"True", alts:["True","true"], explanation:"Row-equivalent matrices have the same null space, so Ax = 0 and Bx = 0 have identical solution sets when A ~ B.", category:"systems"},

    // ===== SPAN =====
    {en:"If b is in the span of the columns of A, then Ax = b is consistent.", fr:"True", alts:["True","true"], explanation:"Ax = b is consistent if and only if b is a linear combination of the columns of A — i.e. b is in Col(A).", category:"span"},
    {en:"Adding a vector to a spanning set always strictly increases the span.", fr:"False", alts:["False","false"], explanation:"If the new vector is already in the current span, adding it changes nothing.", category:"span"},
    {en:"The span of a set of vectors in Rⁿ is always a subspace of Rⁿ.", fr:"True", alts:["True","true"], explanation:"The span of any set satisfies the three subspace conditions: it contains 0, and is closed under addition and scalar multiplication.", category:"span"},
    {en:"The columns of an n×n identity matrix span Rⁿ.", fr:"True", alts:["True","true"], explanation:"The standard basis vectors e₁, …, eₙ span all of Rⁿ.", category:"span"},

    // ===== LINEAR INDEPENDENCE =====
    {en:"A set containing the zero vector is linearly independent.", fr:"False", alts:["False","false"], explanation:"1·0 = 0 gives a nontrivial linear combination equal to zero, so any set containing 0 is dependent.", category:"independence"},
    {en:"If two vectors are scalar multiples of each other, they are linearly dependent.", fr:"True", alts:["True","true"], explanation:"v = c·u means u − (1/c)v = 0 (or similar), a nontrivial combination — so the set is dependent.", category:"independence"},
    {en:"Any set of three vectors in R² must be linearly dependent.", fr:"True", alts:["True","true"], explanation:"In R² there are at most 2 pivots, so any 3 vectors must include a non-pivot column, giving dependence.", category:"independence"},
    {en:"A set of two non-zero vectors is always linearly independent.", fr:"False", alts:["False","false"], explanation:"Two non-zero vectors are dependent if one is a scalar multiple of the other (e.g. [1,2] and [2,4]).", category:"independence"},
    {en:"The columns of a matrix are linearly independent if and only if every column has a pivot.", fr:"True", alts:["True","true"], explanation:"A pivot in every column means Ax = 0 has only the trivial solution — the definition of linear independence.", category:"independence"},
    {en:"A linearly independent set in Rⁿ can contain at most n vectors.", fr:"True", alts:["True","true"], explanation:"Any set of more than n vectors in Rⁿ must be linearly dependent by the counting argument on pivots.", category:"independence"},

    // ===== MATRIX ALGEBRA =====
    {en:"Matrix multiplication is commutative: AB = BA for all matrices A, B.", fr:"False", alts:["False","false"], explanation:"In general, AB ≠ BA. Commutativity fails even for square matrices.", category:"matrices"},
    {en:"The product of two invertible matrices is invertible.", fr:"True", alts:["True","true"], explanation:"(AB)⁻¹ = B⁻¹A⁻¹, so the product of invertible matrices is invertible.", category:"matrices"},
    {en:"If AB = AC and A is invertible, then B = C.", fr:"True", alts:["True","true"], explanation:"Multiply both sides on the left by A⁻¹: B = A⁻¹(AB) = A⁻¹(AC) = C.", category:"matrices"},
    {en:"The transpose of an invertible matrix is also invertible.", fr:"True", alts:["True","true"], explanation:"(Aᵀ)⁻¹ = (A⁻¹)ᵀ, so the transpose inherits invertibility.", category:"matrices"},
    {en:"(AB)ᵀ = AᵀBᵀ for all matrices A, B.", fr:"False", alts:["False","false"], explanation:"The correct identity is (AB)ᵀ = BᵀAᵀ — the order reverses.", category:"matrices"},
    {en:"If A² = 0, then A = 0.", fr:"False", alts:["False","false"], explanation:"Nilpotent matrices satisfy Aᵏ = 0 for some k without being the zero matrix. Example: [[0,1],[0,0]].", category:"matrices"},

    // ===== INVERSES =====
    {en:"A matrix A is invertible if and only if its RREF is the identity matrix.", fr:"True", alts:["True","true"], explanation:"Row reducing [A|I] succeeds to [I|A⁻¹] exactly when A is invertible.", category:"inverses"},
    {en:"A matrix A is invertible if and only if Ax = 0 has only the trivial solution.", fr:"True", alts:["True","true"], explanation:"This is one of the Invertible Matrix Theorem (IMT) equivalences.", category:"inverses"},
    {en:"If det(A) = 0, then A is invertible.", fr:"False", alts:["False","false"], explanation:"det(A) = 0 means A is singular (not invertible). Invertibility requires det(A) ≠ 0.", category:"inverses"},
    {en:"The inverse of a 2×2 matrix [[a,b],[c,d]] is (1/(ad−bc))·[[d,−b],[−c,a]].", fr:"True", alts:["True","true"], explanation:"This is the standard 2×2 inverse formula when det = ad − bc ≠ 0.", category:"inverses"},
    {en:"If A² = I, then A must equal I or −I.", fr:"False", alts:["False","false"], explanation:"Many other matrices satisfy A² = I. For example, [[1,0],[0,−1]] has this property.", category:"inverses"},
    {en:"A non-square matrix cannot be invertible.", fr:"True", alts:["True","true"], explanation:"The standard definition of invertibility requires AB = BA = I, which forces A to be square.", category:"inverses"},

    // ===== ELEMENTARY MATRICES & LU =====
    {en:"Every elementary matrix is invertible.", fr:"True", alts:["True","true"], explanation:"Elementary matrices represent reversible row operations, so each has an inverse (also an elementary matrix).", category:"lu"},
    {en:"In the LU decomposition A = LU, L is upper triangular and U is lower triangular.", fr:"False", alts:["False","false"], explanation:"It is the other way around: L is lower triangular and U is upper triangular.", category:"lu"},
    {en:"Every matrix has an LU factorization.", fr:"False", alts:["False","false"], explanation:"Row swaps may be required during elimination. Without row swaps available, LU may not exist. The general form is PA = LU.", category:"lu"},
    {en:"Row-scaling an elementary matrix (Type II) multiplies the determinant of A by the scale factor.", fr:"True", alts:["True","true"], explanation:"Multiplying a row by c multiplies the determinant by c, since det is multilinear in the rows.", category:"lu"},
    {en:"A row-replacement operation (Type III) does not change the determinant.", fr:"True", alts:["True","true"], explanation:"Adding a multiple of one row to another leaves the determinant unchanged.", category:"lu"},

    // ===== DETERMINANTS =====
    {en:"det(A + B) = det(A) + det(B) for all square matrices A and B.", fr:"False", alts:["False","false"], explanation:"The determinant is NOT additive. det(A + B) ≠ det(A) + det(B) in general.", category:"determinants"},
    {en:"det(AB) = det(A)·det(B) for square matrices A and B.", fr:"True", alts:["True","true"], explanation:"This is the multiplicative property of determinants.", category:"determinants"},
    {en:"If two rows of a matrix are identical, its determinant is zero.", fr:"True", alts:["True","true"], explanation:"Swapping the two equal rows changes the sign of det but doesn't change the matrix, so det = −det, giving det = 0.", category:"determinants"},
    {en:"The determinant of a triangular matrix is the product of its diagonal entries.", fr:"True", alts:["True","true"], explanation:"Cofactor expansion along rows/columns of a triangular matrix reduces to multiplying the diagonal.", category:"determinants"},
    {en:"For a 3×3 matrix A, det(2A) = 2·det(A).", fr:"False", alts:["False","false"], explanation:"Scaling an n×n matrix by c multiplies det by cⁿ. So det(2A) = 2³·det(A) = 8·det(A) for a 3×3 matrix.", category:"determinants"},
    {en:"A square matrix is invertible if and only if its determinant is non-zero.", fr:"True", alts:["True","true"], explanation:"This is a key equivalence in the Invertible Matrix Theorem.", category:"determinants"},
    {en:"det(Aᵀ) = det(A).", fr:"True", alts:["True","true"], explanation:"Transposing a matrix does not change its determinant.", category:"determinants"},

    // ===== LINEAR TRANSFORMATIONS =====
    {en:"A linear transformation must map the zero vector to the zero vector.", fr:"True", alts:["True","true"], explanation:"T(0) = T(0·v) = 0·T(v) = 0 by the homogeneity property of linearity.", category:"transformations"},
    {en:"The standard matrix of T: Rⁿ→Rᵐ is formed by stacking T(eᵢ) as rows.", fr:"False", alts:["False","false"], explanation:"The standard matrix A = [T(e₁) | T(e₂) | … | T(eₙ)] uses T(eᵢ) as COLUMNS, not rows.", category:"transformations"},
    {en:"T: Rⁿ→Rⁿ is invertible if and only if its standard matrix is invertible.", fr:"True", alts:["True","true"], explanation:"Invertibility of T and invertibility of its matrix are equivalent.", category:"transformations"},
    {en:"If T is one-to-one, then T(u) = T(v) implies u = v.", fr:"True", alts:["True","true"], explanation:"That is exactly the definition of one-to-one (injective).", category:"transformations"},
    {en:"A transformation T: Rⁿ→Rᵐ is one-to-one if and only if the columns of its matrix are linearly independent.", fr:"True", alts:["True","true"], explanation:"T is one-to-one iff Ax = 0 has only the trivial solution, which requires linearly independent columns.", category:"transformations"},
    {en:"A transformation T: Rⁿ→Rᵐ is onto if and only if the columns of its matrix span Rᵐ.", fr:"True", alts:["True","true"], explanation:"T is onto iff Ax = b is consistent for every b in Rᵐ, which requires the columns to span Rᵐ.", category:"transformations"},
    {en:"If T: Rⁿ→Rᵐ and n > m, then T cannot be one-to-one.", fr:"True", alts:["True","true"], explanation:"With more columns than rows there must be a free variable, so Ax = 0 has non-trivial solutions.", category:"transformations"},

    // ===== SUBSPACES, NULL SPACE, COL SPACE =====
    {en:"The zero vector belongs to every subspace of Rⁿ.", fr:"True", alts:["True","true"], explanation:"Every subspace must contain the zero vector by definition.", category:"subspaces"},
    {en:"The null space of an m×n matrix A is a subspace of Rⁿ.", fr:"True", alts:["True","true"], explanation:"Nul(A) = {x ∈ Rⁿ : Ax = 0} satisfies all three subspace conditions.", category:"subspaces"},
    {en:"The column space of an m×n matrix A is a subspace of Rⁿ.", fr:"False", alts:["False","false"], explanation:"The columns of A have m entries, so Col(A) is a subspace of Rᵐ, not Rⁿ.", category:"subspaces"},
    {en:"The rank of a matrix equals the number of pivot columns.", fr:"True", alts:["True","true"], explanation:"rank(A) = dim(Col(A)) = number of pivot columns in any echelon form.", category:"subspaces"},
    {en:"For an m×n matrix A, rank(A) + nullity(A) = m.", fr:"False", alts:["False","false"], explanation:"The Rank-Nullity Theorem states rank(A) + nullity(A) = n (the number of columns).", category:"subspaces"},
    {en:"If rank(A) = n for an m×n matrix, then Ax = b has a unique solution for every b.", fr:"False", alts:["False","false"], explanation:"rank(A) = n means the system has at most one solution when consistent, but it may still be inconsistent (no solution) if rank(A) < m.", category:"subspaces"},

    // ===== EIGENVALUES & EIGENVECTORS =====
    {en:"λ is an eigenvalue of A if and only if det(A − λI) = 0.", fr:"True", alts:["True","true"], explanation:"The characteristic equation det(A − λI) = 0 is satisfied exactly when λ is an eigenvalue.", category:"eigenvalues"},
    {en:"The eigenvalues of a triangular matrix are its diagonal entries.", fr:"True", alts:["True","true"], explanation:"For a triangular matrix, det(A − λI) is the product of (aᵢᵢ − λ), so eigenvalues read directly off the diagonal.", category:"eigenvalues"},
    {en:"If A has n distinct eigenvalues (as an n×n matrix), then A is diagonalizable.", fr:"True", alts:["True","true"], explanation:"n distinct eigenvalues guarantee n linearly independent eigenvectors, which form a basis for Rⁿ.", category:"eigenvalues"},
    {en:"The eigenvalues of A and Aᵀ are always the same.", fr:"True", alts:["True","true"], explanation:"det(A − λI) = det((A − λI)ᵀ) = det(Aᵀ − λI), so A and Aᵀ share the same characteristic polynomial.", category:"eigenvalues"},
    {en:"The eigenvectors corresponding to distinct eigenvalues are always linearly independent.", fr:"True", alts:["True","true"], explanation:"Eigenvectors from distinct eigenvalues are always linearly independent — this is a standard theorem.", category:"eigenvalues"},
    {en:"The eigenspace for a given eigenvalue λ is a subspace of Rⁿ.", fr:"True", alts:["True","true"], explanation:"The eigenspace is Nul(A − λI), which is a subspace as it is the null space of a matrix.", category:"eigenvalues"},

    // ===== MARKOV CHAINS =====
    {en:"Every column of a (column) stochastic matrix sums to 1.", fr:"True", alts:["True","true"], explanation:"Each column represents a probability distribution over states, so its entries must sum to 1.", category:"markov"},
    {en:"The steady-state vector q of a regular Markov chain satisfies Pq = q.", fr:"True", alts:["True","true"], explanation:"Pq = q = 1·q, so q is an eigenvector of P for eigenvalue 1.", category:"markov"},
    {en:"A regular Markov chain always has a unique steady-state vector.", fr:"True", alts:["True","true"], explanation:"For a regular stochastic matrix P, the Perron-Frobenius theorem guarantees a unique positive steady-state distribution.", category:"markov"},
    {en:"Eigenvalue 1 always has algebraic multiplicity 1 for a regular stochastic matrix.", fr:"True", alts:["True","true"], explanation:"A regular stochastic matrix has λ = 1 as a simple eigenvalue; all other eigenvalues satisfy |λ| < 1.", category:"markov"}
,

    // ===== ADDITIONAL FALSE CASES (balance) =====
    {en:"If Ax = b is consistent, then the solution is unique.", fr:"False", alts:["False","false"], explanation:"Consistency means at least one solution exists. There may be infinitely many if there are free variables.", category:"systems"},
    {en:"The span of three vectors in R³ is always all of R³.", fr:"False", alts:["False","false"], explanation:"Three vectors in R³ could be linearly dependent (e.g. all in a plane), so their span may be only a 2D subspace.", category:"span"},
    {en:"An eigenvector can be the zero vector.", fr:"False", alts:["False","false"], explanation:"By definition, eigenvectors must be nonzero: Av = λv with v ≠ 0.", category:"eigenvalues"},
    {en:"If A is a 5×3 matrix with rank 3, then Ax = b is consistent for every b in R⁵.", fr:"False", alts:["False","false"], explanation:"Col(A) is only 3-dimensional in R⁵, so most b are not in Col(A) — the system is inconsistent for those b.", category:"subspaces"},
    {en:"Row operations on a matrix change its null space.", fr:"False", alts:["False","false"], explanation:"Row operations preserve the null space. Ax = 0 and any row-reduced form have exactly the same solution set.", category:"systems"},
    {en:"The determinant of an orthogonal matrix is always 1.", fr:"False", alts:["False","false"], explanation:"An orthogonal Q satisfies QᵀQ = I, so det(Q)² = 1, giving det(Q) = ±1. Reflection matrices have det = −1.", category:"determinants"},
    {en:"If AB = 0 and A ≠ 0, then B = 0.", fr:"False", alts:["False","false"], explanation:"Two nonzero matrices can multiply to give zero. Example: [[1,0],[0,0]] · [[0,0],[1,0]] = [[0,0],[0,0]].", category:"matrices"},
    {en:"A linear transformation T: R² → R³ can be onto.", fr:"False", alts:["False","false"], explanation:"The standard matrix is 3×2 with at most 2 pivots, so Col(A) cannot span all of R³.", category:"transformations"},
    {en:"Every system Ax = b where A is square has a unique solution.", fr:"False", alts:["False","false"], explanation:"If A is singular (det = 0), the system either has no solution or infinitely many solutions.", category:"systems"},
    {en:"If nullity(A) = 0, then A must be invertible.", fr:"False", alts:["False","false"], explanation:"Nullity 0 means no free variables, but A could be non-square. Invertibility also requires A to be square.", category:"subspaces"},

  ],

  categoryLabels: {
    all:            "All Topics",
    systems:        "Linear Systems",
    span:           "Span",
    independence:   "Independence",
    matrices:       "Matrix Algebra",
    inverses:       "Inverses",
    lu:             "LU & Elem. Matrices",
    determinants:   "Determinants",
    transformations:"Linear Transformations",
    subspaces:      "Subspaces",
    eigenvalues:    "Eigenvalues",
    markov:         "Markov Chains"
  }
};

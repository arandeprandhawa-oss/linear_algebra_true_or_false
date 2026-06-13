// =====================================================================
// MATH 2210 Applied Linear Algebra — Unit 4 — Subspaces, Eigenvalues & Markov
// True/False flashcards — same format as french-quiz
// =====================================================================

window.ETAPE_DATA = {
  vocab: [
    // ===== SUBSPACES =====
    {en:"The zero vector belongs to every subspace of Rn.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Every subspace must contain the zero vector by definition.", category:"subspaces"},
    {en:"The null space of an m x n matrix A is a subspace of Rn.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Nul(A) = {x in Rn : Ax = 0} satisfies all three subspace conditions.", category:"subspaces"},
    {en:"The column space of an m x n matrix A is a subspace of Rn.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The columns of A are vectors in Rm, so Col(A) is a subspace of Rm, not Rn.", category:"subspaces"},
    {en:"The rank of a matrix equals the number of pivot columns.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"rank(A) = dim(Col(A)) = number of pivot columns in any echelon form.", category:"subspaces"},
    {en:"For an m x n matrix A, rank(A) + nullity(A) = m.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The Rank-Nullity Theorem says rank(A) + nullity(A) = n (the number of columns).", category:"subspaces"},
    {en:"If rank(A) = n for an m x n matrix, then Ax = b has a unique solution for every b.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"rank = n means at most one solution when consistent, but the system may still be inconsistent for some b.", category:"subspaces"},
    {en:"If nullity(A) = 0, then A must be invertible.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Nullity 0 means no free variables, but A could still be non-square. Invertibility also requires A to be square.", category:"subspaces"},
    // ===== EIGENVALUES =====
    {en:"Lambda is an eigenvalue of A if and only if det(A - lambda I) = 0.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The characteristic equation det(A - lambda I) = 0 is satisfied exactly when lambda is an eigenvalue.", category:"eigenvalues"},
    {en:"The eigenvalues of a triangular matrix are its diagonal entries.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"For triangular A, det(A - lambda I) is the product of (aii - lambda), so eigenvalues read off the diagonal.", category:"eigenvalues"},
    {en:"If A has n distinct eigenvalues (as n x n), then A is diagonalizable.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"n distinct eigenvalues guarantee n linearly independent eigenvectors forming a basis for Rn.", category:"eigenvalues"},
    {en:"The eigenvalues of A and A transpose are always the same.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"det(A - lambda I) = det((A - lambda I) transpose) = det(A transpose - lambda I), same characteristic polynomial.", category:"eigenvalues"},
    {en:"The eigenvectors corresponding to distinct eigenvalues are always linearly independent.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This is a standard theorem: eigenvectors from distinct eigenvalues are always independent.", category:"eigenvalues"},
    {en:"An eigenvector can be the zero vector.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"By definition, eigenvectors must be nonzero: Av = lambda v with v not equal to 0.", category:"eigenvalues"},
    {en:"The eigenspace for a given eigenvalue lambda is a subspace of Rn.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The eigenspace is Nul(A - lambda I), which is the null space of a matrix — always a subspace.", category:"eigenvalues"},
    // ===== MARKOV CHAINS =====
    {en:"Every column of a (column) stochastic matrix sums to 1.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Each column represents a probability distribution over states, so its entries must sum to 1.", category:"markov"},
    {en:"The steady-state vector q of a regular Markov chain satisfies Pq = q.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Pq = q = 1 times q, so q is an eigenvector of P for eigenvalue 1.", category:"markov"},
    {en:"A regular Markov chain always has a unique steady-state vector.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The Perron-Frobenius theorem guarantees a unique positive steady-state distribution for a regular stochastic matrix.", category:"markov"},
    {en:"Eigenvalue 1 always has algebraic multiplicity 1 for a regular stochastic matrix.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"A regular stochastic matrix has lambda = 1 as a simple eigenvalue; all other eigenvalues satisfy |lambda| < 1.", category:"markov"},
  ],
  categoryLabels: {
    all:"All Topics",
    subspaces:"Subspaces",
    eigenvalues:"Eigenvalues",
    markov:"Markov Chains",
  }
};
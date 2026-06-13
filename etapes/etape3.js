// =====================================================================
// MATH 2210 Applied Linear Algebra — Unit 3 — Determinants & Linear Transformations
// True/False flashcards — same format as french-quiz
// =====================================================================

window.ETAPE_DATA = {
  vocab: [
    // ===== DETERMINANTS =====
    {en:"det(A + B) = det(A) + det(B) for all square matrices.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The determinant is not additive. In general det(A+B) does not equal det(A) + det(B).", category:"determinants"},
    {en:"det(AB) = det(A) times det(B) for square matrices A and B.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This is the multiplicative property of determinants.", category:"determinants"},
    {en:"If two rows of a matrix are identical, its determinant is zero.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Swapping the two equal rows changes the sign but not the matrix, so det = -det, giving det = 0.", category:"determinants"},
    {en:"The determinant of a triangular matrix is the product of its diagonal entries.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Cofactor expansion on a triangular matrix reduces to multiplying the diagonal.", category:"determinants"},
    {en:"For a 3x3 matrix A, det(2A) = 2 times det(A).", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Scaling an n x n matrix by c multiplies det by c^n. So det(2A) = 8 det(A) for a 3x3 matrix.", category:"determinants"},
    {en:"A square matrix is invertible if and only if its determinant is nonzero.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This is a key equivalence in the Invertible Matrix Theorem.", category:"determinants"},
    {en:"det(A transpose) = det(A).", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Transposing a matrix does not change its determinant.", category:"determinants"},
    {en:"Every matrix with a zero row has determinant zero.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"A zero row makes the rows linearly dependent, which forces det = 0.", category:"determinants"},
    {en:"The determinant of an orthogonal matrix is always 1.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"An orthogonal Q satisfies Q^T Q = I so det(Q)^2 = 1, giving det(Q) = plus or minus 1. Reflection matrices have det = -1.", category:"determinants"},
    // ===== LINEAR TRANSFORMATIONS =====
    {en:"A linear transformation must map the zero vector to the zero vector.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"T(0) = T(0 times v) = 0 times T(v) = 0 by the homogeneity property.", category:"transformations"},
    {en:"The standard matrix of T: Rn to Rm is formed by stacking T(ei) as rows.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The standard matrix uses T(e1), T(e2), ..., T(en) as COLUMNS, not rows.", category:"transformations"},
    {en:"T: Rn to Rn is invertible if and only if its standard matrix is invertible.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Invertibility of T and of its matrix are equivalent.", category:"transformations"},
    {en:"T: Rn to Rm is one-to-one if and only if its columns are linearly independent.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"T is one-to-one iff Ax = 0 has only the trivial solution, which requires independent columns.", category:"transformations"},
    {en:"T: Rn to Rm is onto if and only if its columns span Rm.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"T is onto iff Ax = b is consistent for every b, which requires columns to span Rm.", category:"transformations"},
    {en:"If T: Rn to Rm and n > m, then T can be one-to-one.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"With more columns than rows there must be a free variable, so Ax = 0 has nontrivial solutions.", category:"transformations"},
    {en:"If T is one-to-one, then T(u) = T(v) implies u = v.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"That is exactly the definition of one-to-one (injective).", category:"transformations"},
    {en:"A linear transformation T: R2 to R3 can be onto.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The matrix is 3x2 with at most 2 pivots, so the columns cannot span all of R3.", category:"transformations"},
  ],
  categoryLabels: {
    all:"All Topics",
    determinants:"Determinants",
    transformations:"Linear Transformations",
  }
};
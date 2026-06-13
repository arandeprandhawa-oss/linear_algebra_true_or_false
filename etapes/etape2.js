// =====================================================================
// MATH 2210 Applied Linear Algebra — Unit 2 — Matrix Algebra, Inverses & LU
// True/False flashcards — same format as french-quiz
// =====================================================================

window.ETAPE_DATA = {
  vocab: [
    // ===== MATRIX ALGEBRA =====
    {en:"Matrix multiplication is commutative: AB = BA for all matrices A and B.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"In general AB is not equal to BA — commutativity fails even for square matrices.", category:"matrices"},
    {en:"The product of two invertible matrices is invertible.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"(AB) inverse = B inverse times A inverse, so the product inherits invertibility.", category:"matrices"},
    {en:"If AB = AC and A is invertible, then B = C.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Multiply both sides on the left by A inverse to get B = C.", category:"matrices"},
    {en:"The transpose of an invertible matrix is also invertible.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"(A transpose) inverse = (A inverse) transpose, so the transpose inherits invertibility.", category:"matrices"},
    {en:"(AB) transpose = A transpose times B transpose.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The correct rule reverses the order: (AB) transpose = B transpose times A transpose.", category:"matrices"},
    {en:"If A squared = 0, then A = 0.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Nilpotent matrices satisfy A^k = 0 without being the zero matrix. Example: [[0,1],[0,0]].", category:"matrices"},
    {en:"If AB = 0 and A is not 0, then B = 0.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Two nonzero matrices can multiply to give the zero matrix.", category:"matrices"},
    // ===== INVERSES =====
    {en:"A matrix A is invertible if and only if its RREF is the identity matrix.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Row reducing [A|I] succeeds to [I|A inverse] exactly when A is invertible.", category:"inverses"},
    {en:"A matrix A is invertible if and only if Ax = 0 has only the trivial solution.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This is one of the Invertible Matrix Theorem equivalences.", category:"inverses"},
    {en:"If det(A) = 0, then A is invertible.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"det(A) = 0 means A is singular. Invertibility requires det(A) not equal to 0.", category:"inverses"},
    {en:"The inverse of a 2x2 matrix [[a,b],[c,d]] is (1/(ad-bc)) times [[d,-b],[-c,a]].", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"This is the standard 2x2 inverse formula when ad - bc is not 0.", category:"inverses"},
    {en:"If A squared = I, then A = I or A = -I.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Many other matrices satisfy A^2 = I. For example [[1,0],[0,-1]] has this property.", category:"inverses"},
    {en:"A non-square matrix cannot be invertible.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Invertibility requires AB = BA = I, which forces A to be square.", category:"inverses"},
    {en:"The null space of an invertible n x n matrix contains more than just the zero vector.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"If A is invertible, Ax = 0 implies x = 0. So Nul(A) = {0}.", category:"inverses"},
    // ===== ELEMENTARY MATRICES & LU =====
    {en:"Every elementary matrix is invertible.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Elementary matrices represent reversible row operations, so each has an inverse.", category:"lu"},
    {en:"In the LU decomposition A = LU, L is upper triangular and U is lower triangular.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"It is the other way: L is lower triangular and U is upper triangular.", category:"lu"},
    {en:"Every matrix has an LU factorization.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Row swaps may be required. The general form needs a permutation: PA = LU.", category:"lu"},
    {en:"A row-replacement operation (Type III) does not change the determinant.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Adding a multiple of one row to another leaves the determinant unchanged.", category:"lu"},
    {en:"Row-scaling a matrix (Type II) multiplies its determinant by the scale factor.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Multiplying a row by c multiplies det by c, since det is linear in each row.", category:"lu"},
  ],
  categoryLabels: {
    all:"All Topics",
    matrices:"Matrix Algebra",
    inverses:"Inverses",
    lu:"LU & Elem. Matrices",
  }
};
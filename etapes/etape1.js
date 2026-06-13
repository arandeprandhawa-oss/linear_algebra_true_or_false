// =====================================================================
// MATH 2210 Applied Linear Algebra — Unit 1 — Linear Systems, Span & Independence
// True/False flashcards — same format as french-quiz
// =====================================================================

window.ETAPE_DATA = {
  vocab: [
    // ===== LINEAR SYSTEMS =====
    {en:"A homogeneous system Ax = 0 can be inconsistent.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Ax = 0 always has the trivial solution x = 0, so it is always consistent.", category:"systems"},
    {en:"If an augmented matrix [A|b] has a pivot in the last column, the system is inconsistent.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"A pivot in the last column gives a row [0 ... 0 | c] with c not 0 — a contradiction.", category:"systems"},
    {en:"Every matrix has a unique reduced row echelon form (RREF).", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The RREF is unique regardless of which row operations are used.", category:"systems"},
    {en:"A consistent system with no free variables has exactly one solution.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"No free variables means every variable is determined by a pivot.", category:"systems"},
    {en:"A 3x5 system can have a unique solution.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"A 3x5 matrix has at most 3 pivots, leaving at least 2 free variables — so if consistent it has infinitely many solutions.", category:"systems"},
    {en:"If a linear system has more unknowns than equations, it must have infinitely many solutions.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"It could also be inconsistent. More unknowns than equations rules out a unique solution but not all solutions.", category:"systems"},
    {en:"Two row-equivalent matrices always have the same null space.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Row operations preserve the solution set of Ax = 0.", category:"systems"},
    {en:"If Ax = b is consistent, then the solution is unique.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Consistency only means at least one solution exists. Free variables may give infinitely many.", category:"systems"},
    {en:"Row operations on a matrix change its null space.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Row operations preserve the null space — Ax = 0 and any row-reduced form have the same solution set.", category:"systems"},
    {en:"Every square system Ax = b has a unique solution.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"If A is singular (det = 0), the system has no solution or infinitely many.", category:"systems"},
    // ===== SPAN =====
    {en:"If b is in the span of the columns of A, then Ax = b is consistent.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Ax = b is consistent exactly when b is in the column space (span of columns) of A.", category:"span"},
    {en:"Adding a vector to a spanning set always strictly increases the span.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"If the new vector is already in the current span, the span does not change.", category:"span"},
    {en:"The span of any set of vectors in Rn is a subspace of Rn.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The span satisfies all three subspace conditions: contains 0, closed under addition and scalar multiplication.", category:"span"},
    {en:"The span of three vectors in R3 is always all of R3.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Three vectors in R3 could be dependent and span only a 2D subspace.", category:"span"},
    {en:"The columns of the n x n identity matrix span Rn.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"The standard basis vectors e1,...,en span all of Rn.", category:"span"},
    // ===== LINEAR INDEPENDENCE =====
    {en:"A set containing the zero vector is linearly independent.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"1 times 0 = 0 gives a nontrivial combination, so any set with the zero vector is dependent.", category:"independence"},
    {en:"If two vectors are scalar multiples of each other, they are linearly dependent.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"One can be written as a multiple of the other, giving a nontrivial combination equal to zero.", category:"independence"},
    {en:"Any set of three vectors in R2 must be linearly dependent.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"In R2 there are at most 2 pivots, so any 3 vectors must include a non-pivot column giving dependence.", category:"independence"},
    {en:"A set of two non-zero vectors is always linearly independent.", fr:"False", alts:["False","false"], needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Two non-zero vectors can be scalar multiples of each other (e.g. [1,2] and [2,4]) making them dependent.", category:"independence"},
    {en:"The columns of a matrix are linearly independent if and only if every column has a pivot.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"A pivot in every column means Ax = 0 has only the trivial solution — the definition of independence.", category:"independence"},
    {en:"A linearly independent set in Rn can contain at most n vectors.", fr:"True",  alts:["True","true"],   needsHyphen:false, needsAccent:false, gender:"both", guessGender:true, explanation:"Any set of more than n vectors in Rn must be linearly dependent.", category:"independence"},
  ],
  categoryLabels: {
    all:"All Topics",
    systems:"Linear Systems",
    span:"Span",
    independence:"Linear Independence",
  }
};
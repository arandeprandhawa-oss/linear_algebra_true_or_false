window.ETAPE_DATA = {
  vocab: [
    {
      en: "Every square matrix is invertible.",
      fr: "False",
      alts: ["False", "false"],
      explanation: "A square matrix is invertible only when its determinant is nonzero.",
      needsHyphen: false,
      needsAccent: false,
      gender: "both",
      category: "matrices"
    },

    {
      en: "The zero vector belongs to every subspace.",
      fr: "True",
      alts: ["True", "true"],
      explanation: "Every subspace must contain the zero vector.",
      needsHyphen: false,
      needsAccent: false,
      gender: "both",
      category: "subspaces"
    },

    {
      en: "If det(A) = 0, then A is invertible.",
      fr: "False",
      alts: ["False", "false"],
      explanation: "A matrix is invertible only when det(A) is not zero.",
      needsHyphen: false,
      needsAccent: false,
      gender: "both",
      category: "determinants"
    },

    {
      en: "A set containing the zero vector is linearly independent.",
      fr: "False",
      alts: ["False", "false"],
      explanation: "Any set containing the zero vector is linearly dependent.",
      needsHyphen: false,
      needsAccent: false,
      gender: "both",
      category: "independence"
    },

    {
      en: "A linear transformation must map the zero vector to the zero vector.",
      fr: "True",
      alts: ["True", "true"],
      explanation: "Linearity gives T(0) = 0.",
      needsHyphen: false,
      needsAccent: false,
      gender: "both",
      category: "transformations"
    },

    {
      en: "If two vectors are scalar multiples of each other, they are linearly dependent.",
      fr: "True",
      alts: ["True", "true"],
      explanation: "One vector can be written as a multiple of the other.",
      needsHyphen: false,
      needsAccent: false,
      gender: "both",
      category: "independence"
    }
  ],

  categoryLabels: {
    all: "Random",
    matrices: "Matrices",
    determinants: "Determinants",
    subspaces: "Subspaces",
    independence: "Linear Independence",
    transformations: "Linear Transformations"
  }
};

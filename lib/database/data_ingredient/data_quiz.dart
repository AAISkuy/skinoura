import 'package:skinoura/models/question_model.dart';

final List<Question> skinQuizQuestions = [
  Question(
    questionText:
        "Bagaimana kondisi wajahmu di siang hari beberapa jam setelah cuci muka?",
    options: [
      AnswerOption(
        optionText: "Mengkilap, sangat berminyak di seluruh area wajah.",
        skinType: "Oily",
        recommendedIngredients: [
          "Salicylic Acid (BHA)",
          "Niacinamide",
          "Centella Asiatica (Cica)",
          "Zinc PCA",
        ],
      ),
      AnswerOption(
        optionText:
            "Terasa kering, kaku/ketarik, bahkan ada bagian yang sampai mengelupas/bersisik.",
        skinType: "Dry",
        recommendedIngredients: [
          "Hyaluronic Acid",
          "Ceramide",
          "Glycerin",
          "Squalane",
        ],
      ),
      AnswerOption(
        optionText:
            "Berminyak parah di dahi, hidung, dan dagu (T-Zone), tapi pipi terasa kering atau biasa aja.",
        skinType: "Combination",
        recommendedIngredients: [
          "Niacinamide",
          "Hyaluronic Acid",
          "Green Tea Extract",
        ],
      ),
      AnswerOption(
        optionText: "Terasa nyaman, tidak terlalu berminyak ataupun kering.",
        skinType: "Normal",
        recommendedIngredients: ["Vitamin C", "Hyaluronic Acid", "Niacinamide"],
      ),
    ],
  ),

  // PERTANYAAN 2: SENSITIVITAS & REAKSI KULIT
  Question(
    questionText:
        "Bagaimana reaksi kulit wajahmu ketika mencoba produk skincare baru yang kurang cocok?",
    options: [
      AnswerOption(
        optionText:
            "Langsung terasa perih, gatal, muncul rona kemerahan, atau bruntusan gatal.",
        skinType: "Sensitive",
        recommendedIngredients: [
          "Centella Asiatica (Cica)",
          "Allantoin",
          "Ceramide",
          "Panthenol",
        ],
      ),
      AnswerOption(
        optionText:
            "Kadang agak gatal atau merah, tapi cepat hilang dalam hitungan jam.",
        skinType: "Combination",
        recommendedIngredients: ["Allantoin", "Niacinamide"],
      ),
      AnswerOption(
        optionText:
            "Sama sekali tidak bereaksi negatif, kulit tergolong 'badak' saat coba produk baru.",
        skinType: "Normal",
        recommendedIngredients: ["Retinol", "Glycolic Acid (AHA)"],
      ),
    ],
  ),

  // PERTANYAAN 3: KONDISI PORI-PORI & JERAWAT
  Question(
    questionText:
        "Bagaimana tampilan pori-pori dan masalah jerawat di wajahmu saat ini?",
    options: [
      AnswerOption(
        optionText:
            "Pori-pori terlihat besar di sekitar hidung dan pipi, serta sering muncul komedo dan jerawat aktif.",
        skinType: "Oily",
        recommendedIngredients: [
          "Salicylic Acid (BHA)",
          "Tea Tree Oil",
          "Niacinamide",
        ],
      ),
      AnswerOption(
        optionText:
            "Pori-pori hampir tidak terlihat, jarang jerawatan, tapi kulit kelihatan kusam dan kurang kenyal.",
        skinType: "Dry",
        recommendedIngredients: ["Glycerin", "Hyaluronic Acid", "Vitamin E"],
      ),
      AnswerOption(
        optionText:
            "Pori-pori besar dan berkomedo hanya di area hidung/T-Zone, area wajah lainnya mulus.",
        skinType: "Combination",
        recommendedIngredients: [
          "Salicylic Acid (BHA)",
          "Witch Hazel",
          "Hyaluronic Acid",
        ],
      ),
    ],
  ),

  // PERTANYAAN 4: TEKSTUR KULIT
  Question(
    questionText:
        "Saat kamu meraba kulit wajah dengan tangan, apa yang paling kamu rasakan?",
    options: [
      AnswerOption(
        optionText:
            "Terasa licin karena minyak, lengket, dan teksturnya tidak merata akibat bruntusan/jerawat.",
        skinType: "Oily",
        recommendedIngredients: [
          "Salicylic Acid (BHA)",
          "Centella Asiatica (Cica)",
        ],
      ),
      AnswerOption(
        optionText:
            "Terasa kasar, kering, tipis, dan kurang elastis saat dicubit lembut.",
        skinType: "Dry",
        recommendedIngredients: ["Ceramide", "Squalane", "Shea Butter"],
      ),
      AnswerOption(
        optionText:
            "Mudah terasa perih/panas jika digosok terlalu kuat, kulit terasa sangat tipis.",
        skinType: "Sensitive",
        recommendedIngredients: ["Panthenol", "Madecassoside", "Ceramide"],
      ),
    ],
  ),
];

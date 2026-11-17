import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:provider/provider.dart';
import 'package:islami/dezeen/shiar.dart';

class QuizQuestion {
  final String category;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  QuizQuestion({
    required this.category,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

final List<QuizQuestion> islamicQuizQuestions = [
  QuizQuestion(
    category: "القرآن الكريم",
    question: "ما هي أقصر سورة في القرآن الكريم من حيث عدد الآيات؟",
    options: ["سورة الإخلاص", "سورة الكوثر", "سورة النصر", "سورة العصر"],
    correctAnswerIndex: 1,
    explanation: "سورة الكوثر هي أقصر سور القرآن الكريم، وتتألف من ثلاث آيات فقط.",
  ),
  QuizQuestion(
    category: "القرآن الكريم",
    question: "أي سورة تعدل قراءتها ثلث القرآن الكريم كما ورد في الحديث الصحيح؟",
    options: ["سورة الفاتحة", "سورة يس", "سورة الإخلاص", "سورة الملك"],
    correctAnswerIndex: 2,
    explanation: "قال النبي ﷺ عن سورة الإخلاص: (والذي نفسي بيده إنها لتعدل ثلث القرآن) لاشتمالها على التوحيد الخالص.",
  ),
  QuizQuestion(
    category: "القرآن الكريم",
    question: "ما هي السورة المانعة والمنجية من عذاب القبر لمن حافظ على قراءتها؟",
    options: ["سورة الملك", "سورة الواقعة", "سورة الرحمن", "سورة الكهف"],
    correctAnswerIndex: 0,
    explanation: "ورد في الحديث الصحيح أن سورة الملك (ثلاثون آية) تشفع لصاحبها وتنجيه من عذاب القبر.",
  ),
  QuizQuestion(
    category: "الأنبياء والرسل",
    question: "من هو النبي الذي أُلقي في النار فجعلها الله برداً وسلاماً عليه؟",
    options: ["موسى عليه السلام", "إبراهيم عليه السلام", "نوح عليه السلام", "عيسى عليه السلام"],
    correctAnswerIndex: 1,
    explanation: "هو إبراهيم خليل الله عليه السلام حين كاده قومه فألقوه في النار فأنجاه الله.",
  ),
  QuizQuestion(
    category: "الأنبياء والرسل",
    question: "من هو النبي الملقب بذو النون؟",
    options: ["يوسف عليه السلام", "يونس عليه السلام", "زكريا عليه السلام", "أيوب عليه السلام"],
    correctAnswerIndex: 1,
    explanation: "هو يونس عليه السلام الذي التقمه الحوت فنادى في الظلمات.",
  ),
  QuizQuestion(
    category: "السيرة النبوية",
    question: "في أي عام هجري وقعت غزوة بدر الكبرى؟",
    options: ["السنة الأولى للهجرة", "السنة الثانية للهجرة", "السنة الثالثة للهجرة", "السنة الرابعة للهجرة"],
    correctAnswerIndex: 1,
    explanation: "وقعت غزوة بدر الكبرى في السابع عشر من رمضان في السنة الثانية للهجرة.",
  ),
  QuizQuestion(
    category: "السيرة النبوية",
    question: "من هو الصحابي الذي لُقب بـ (أسد الله)؟",
    options: ["علي بن أبي طالب", "حمزة بن عبد المطلب", "عمر بن الخطاب", "خالد بن الوليد"],
    correctAnswerIndex: 1,
    explanation: "هو عم النبي ﷺ حمزة بن عبد المطلب رضي الله عنه.",
  ),
  QuizQuestion(
    category: "العبادات والأذكار",
    question: "كم عدد ركعات الصلوات المفروضة في اليوم والليلة؟",
    options: ["12 ركعة", "15 ركعة", "17 ركعة", "21 ركعة"],
    correctAnswerIndex: 2,
    explanation: "الصلوات المفروضة 17 ركعة: الفجر 2، الظهر 4، العصر 4، المغرب 3، العشاء 4.",
  ),
  QuizQuestion(
    category: "العبادات والأذكار",
    question: "ما هو أفضل الذكر كما ورد عن النبي ﷺ؟",
    options: ["سبحان الله", "الحمد لله", "لا إله إلا الله", "الله أكبر"],
    correctAnswerIndex: 2,
    explanation: "قال النبي ﷺ: (أفضل الذكر لا إله إلا الله، وأفضل الدعاء الحمد لله).",
  ),
];

class IslamicQuizScreen extends StatefulWidget {
  static const String routeName = "IslamicQuizScreen";

  const IslamicQuizScreen({super.key});

  @override
  State<IslamicQuizScreen> createState() => _IslamicQuizScreenState();
}

class _IslamicQuizScreenState extends State<IslamicQuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _answered = false;

  void _answerQuestion(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswerIndex = index;
      _answered = true;
      if (index == islamicQuizQuestions[_currentIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentIndex < islamicQuizQuestions.length - 1) {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _answered = false;
      } else {
        _showResultDialog();
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _answered = false;
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("نتيجة المسابقة 🌟", textAlign: TextAlign.center),
        content: Text(
          "لقد أتممت التحدي بنجاح!\n\nنتيجتك: $_score من ${islamicQuizQuestions.length}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _restartQuiz();
            },
            child: const Text("إعادة المسابقة"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("الرجوع للرئيسية"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();
    final question = islamicQuizQuestions[_currentIndex];

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(isDark ? AppImage.backgroundDark : AppImage.backgroundHome),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.yellow, size: 26),
            tooltip: "رجوع",
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(
            "المسابقات والتحديات الإسلامية",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.yellow),
          ),
          centerTitle: true,
          actions: [_ThemeToggle()],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // شريط التقدم والنقاط
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.yellow),
                      ),
                      child: Text(
                        "السؤال ${_currentIndex + 1} من ${islamicQuizQuestions.length}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        "النقاط: $_score",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // بطاقة السؤال
                Card(
                  color: isDark ? AppColors.yellowDark : Colors.white.withValues(alpha: 0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: AppColors.yellow.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Chip(
                          label: Text(question.category, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          backgroundColor: AppColors.yellow,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          question.question,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // خيارات الإجابة
                Expanded(
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      Color btnColor = isDark ? const Color(0xFF1E2229) : Colors.white;
                      Color borderColor = AppColors.yellow.withValues(alpha: 0.5);
                      Color textColor = isDark ? Colors.white : Colors.black87;

                      if (_answered) {
                        if (index == question.correctAnswerIndex) {
                          btnColor = Colors.green.shade100;
                          borderColor = Colors.green;
                        } else if (index == _selectedAnswerIndex) {
                          btnColor = Colors.red.shade100;
                          borderColor = Colors.red;
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: btnColor,
                            side: BorderSide(color: borderColor, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          ),
                          onPressed: () => _answerQuestion(index),
                          child: Text(
                            question.options[index],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // التوضيح عند الإجابة
                if (_answered) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.yellow),
                    ),
                    child: Text(
                      "💡 ${question.explanation}",
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _nextQuestion,
                    child: Text(
                      _currentIndex < islamicQuizQuestions.length - 1 ? "السؤال التالي ➔" : "عرض النتيجة النهائية 🏆",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();
    return ThemeSwitcher(
      builder: (ctx) => SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppColors.yellow, size: 26),
          tooltip: isDark ? "الوضع الفاتح" : "الوضع الداكن",
          onPressed: () {
            provider.changeTheme(isDark ? ThemeMode.light : ThemeMode.dark);
            ThemeSwitcher.of(ctx).changeTheme(theme: isDark ? Apptheme.lightTheme : Apptheme.darkTheme);
          },
        ),
      ),
    );
  }
}

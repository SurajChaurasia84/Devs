import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class CodeHighlighter extends StatefulWidget {
  final String code;
  final String language;

  const CodeHighlighter({
    super.key,
    required this.code,
    required this.language,
  });

  @override
  State<CodeHighlighter> createState() => _CodeHighlighterState();
}

class _CodeHighlighterState extends State<CodeHighlighter> {
  bool _copied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() {
      _copied = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Code copied to clipboard!',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: AppTheme.primaryBlue,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  List<TextSpan> _highlightCode(String code, bool isDark) {
    final keywordStyle = TextStyle(
      color: AppTheme.primaryBlue,
      fontWeight: FontWeight.bold,
      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    );
    final commentStyle = TextStyle(
      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
      fontStyle: FontStyle.italic,
      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    );
    final normalStyle = TextStyle(
      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    );

    final List<TextSpan> spans = [];

    // Simple regex matching comments (Group 1) and keywords (Group 2)
    final regex = RegExp(
      r'(//.*|#.*|/\*[\s\S]*?\*/)' // Group 1: Comments (single & multi line)
      r'|'
      r'\b(class|import|void|final|const|return|if|else|for|while|package|fun|val|var|func|def|struct|impl|let|mut|pub|interface|extends|implements|new|this|super|override|import|as|from|export|default|require|module|const|let|var|switch|case|break)\b', // Group 2: Keywords
    );

    code.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final matchedText = match.group(0)!;
        if (match.group(1) != null) {
          spans.add(TextSpan(text: matchedText, style: commentStyle));
        } else {
          spans.add(TextSpan(text: matchedText, style: keywordStyle));
        }
        return '';
      },
      onNonMatch: (String nonMatch) {
        spans.add(TextSpan(text: nonMatch, style: normalStyle));
        return '';
      },
    );

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final lines = widget.code.split('\n');

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderCol, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Window Buttons (Minimalist grey)
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF555555),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF555555),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF555555),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                // Language indicator
                Text(
                  widget.language.toUpperCase(),
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                // Copy Action
                GestureDetector(
                  onTap: _copyToClipboard,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _copied ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      _copied ? LucideIcons.check : LucideIcons.copy,
                      size: 14,
                      color: _copied
                          ? AppTheme.primaryBlue
                          : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code Display Area
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line Numbers
                Container(
                  width: 32,
                  padding: const EdgeInsets.only(right: 8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      return Text(
                        '${index + 1}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.jetBrainsMono(
                          color: isDark ? const Color(0xFF444444) : const Color(0xFFCCCCCC),
                          fontSize: 11,
                          height: 1.5,
                        ),
                      );
                    },
                  ),
                ),
                // Code content
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: RichText(
                      text: TextSpan(
                        children: _highlightCode(widget.code, isDark),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

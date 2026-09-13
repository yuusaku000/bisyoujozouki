import 'package:flutter/material.dart';

import '../data/organs.dart';
import '../data/sounds.dart';
import '../data/theme.dart';
import '../models/organ.dart';
import '../services/audio.dart';

/// はじめて開いた瞬間。説明より先に、一戦させる。
///
/// 最初に操作説明を読ませても頭に入らない。先に戦って、
/// 最初の話が開いた状態にしてから案内したほうが、読む理由ができる。
class IntroOverlay extends StatefulWidget {
  const IntroOverlay({super.key, required this.onBattle});

  final VoidCallback onBattle;

  @override
  State<IntroOverlay> createState() => _IntroOverlayState();
}

class _IntroOverlayState extends State<IntroOverlay> {
  /// まだ出会っていない時点の声。
  ///
  /// 「聞こえてる？」の驚きは第1話でやる。ここで先に言ってしまうと、
  /// 戦いのあとの初対面が二度手間になる。ここは警告だけにとどめる。
  static const List<(String, Condition)> _lines = [
    ('——来る。', Condition.fuchou),
    ('こんな時間に、あんなもの食べるから。', Condition.fuchou),
    ('いい？　そこ、動かないで。', Condition.futsuu),
    ('説明はあと。いまは、見てて。', Condition.fuchou),
  ];

  int _index = 0;

  void _next() {
    Audio.instance.playSfx(Sfx.page);
    if (_index == _lines.length - 1) {
      widget.onBattle();
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    final heart = organById('heart');
    final (text, face) = _lines[_index];

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _next,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xD9090409)),
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.78,
                child: Image.asset(heart.imagePath(face), fit: BoxFit.contain),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 34),
                child: _bubble(heart, text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(Organ heart, String text) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.panelGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.rose, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.rose.withValues(alpha: 0.4),
            blurRadius: 26,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heart.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: heart.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 15, height: 1.6)),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _index == _lines.length - 1 ? 'たたかう' : 'タップでつづき',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.rose,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 案内で指したい場所。ホームの各部品に付けておく。
class HomeAnchors {
  final GlobalKey today = GlobalKey();
  final GlobalKey coin = GlobalKey();
  final GlobalKey story = GlobalKey();
  final GlobalKey party = GlobalKey();
  final GlobalKey record = GlobalKey();
  final GlobalKey battle = GlobalKey();
  final GlobalKey nav = GlobalKey();
}

class TutorialStep {
  const TutorialStep({required this.text, this.target, this.face});

  final String text;

  /// 指す場所。null なら画面全体に話しかける。
  final GlobalKey? target;

  final Condition? face;
}

/// はじめて開いた人への案内。
///
/// 説明書を別に置いても読まれない。せっかく喋る子がいるので、
/// 本人にこの画面を案内してもらう。
class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({
    super.key,
    required this.anchors,
    required this.onDone,
  });

  final HomeAnchors anchors;
  final VoidCallback onDone;

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  int _index = 0;

  late final List<TutorialStep> _steps = [
    TutorialStep(
      text:
          '……で。さっきの続きなんだけど。\n'
          '説明もしないで戦わせて、ごめんね。\n改めて、この画面を案内する。',
      face: Condition.genki,
    ),
    TutorialStep(
      target: widget.anchors.today,
      text: 'ここが今日の日付と、今日の目標歩数。\nこの歩数を超えるのが、今日の目標よ。',
    ),
    TutorialStep(
      target: widget.anchors.coin,
      text: '歩いた分がコインになるの。1歩で1コイン。\n階段をのぼると、もっと増えるわ。',
    ),
    TutorialStep(
      target: widget.anchors.record,
      text:
          '一日の終わりに、ここから歩数を入れて。\n……これがいちばん大事。'
          'わたしたちの調子は、これで決まるの。',
      face: Condition.futsuu,
    ),
    TutorialStep(
      target: widget.anchors.battle,
      text:
          'ここから、不摂生をやっつけに行くの。\n'
          '戦うのはわたしたち。あなたは見ててくれればいいよ。',
    ),
    TutorialStep(
      target: widget.anchors.party,
      text:
          'ここで、わたしたちを切り替えられる。\n'
          'まだ会ってない子は……お話を読むと、来てくれるから。',
    ),
    TutorialStep(
      target: widget.anchors.story,
      text:
          'お話は、ここにしまってあるよ。\n'
          '赤い丸は、まだ読んでいない印。',
    ),
    TutorialStep(
      target: widget.anchors.nav,
      text: '育成でレベル上げ、ガチャでプレゼント、\nショップで鍵が買えるわ。あとで見てみて。',
    ),
    TutorialStep(
      text: '……以上。あとは、好きにやってくれていいよ。\nわたしはずっと、ここにいるから。',
      face: Condition.genki,
    ),
  ];

  TutorialStep get _step => _steps[_index];

  bool get _isLast => _index == _steps.length - 1;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _next() {
    Audio.instance.playSfx(Sfx.page);
    if (_isLast) {
      widget.onDone();
      return;
    }
    setState(() => _index++);
  }

  /// 指す場所の画面上の位置。まだ描かれていなければ null。
  Rect? _targetRect() {
    final key = _step.target;
    if (key == null) return null;

    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;

    final origin = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      origin.dx,
      origin.dy,
      box.size.width,
      box.size.height,
    ).inflate(7);
  }

  @override
  Widget build(BuildContext context) {
    final hole = _targetRect();
    final size = MediaQuery.of(context).size;

    // 穴が上半分なら下に、下半分なら上に置く。指した場所を隠さないように。
    final below = hole != null && hole.center.dy < size.height * 0.45;

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _next,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) => CustomPaint(
                size: Size.infinite,
                painter: _Spotlight(hole: hole, pulse: _pulse.value),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: hole == null ? null : (below ? hole.bottom + 16 : null),
              bottom: hole == null
                  ? null
                  : (below ? null : size.height - hole.top + 16),
              child: hole == null
                  ? SizedBox(
                      height: size.height,
                      child: Center(child: _panel()),
                    )
                  : _panel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panel() {
    final heart = organById('heart');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.panelGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.rose, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: AppColors.rose.withValues(alpha: 0.4),
              blurRadius: 26,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.rose, width: 1.6),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      heart.facePath(_step.face ?? Condition.genki),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heart.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: heart.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _step.text,
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // どこまで来たか。終わりが見えないと読み飛ばしたくなる。
                for (var i = 0; i < _steps.length; i++)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= _index
                          ? AppColors.rose
                          : AppColors.textMuted.withValues(alpha: 0.35),
                    ),
                  ),
                const Spacer(),
                if (!_isLast)
                  GestureDetector(
                    onTap: widget.onDone,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'スキップ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                Text(
                  _isLast ? 'はじめる' : 'タップでつづき',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.rose,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 指した場所だけ穴を開けて暗くする。
class _Spotlight extends CustomPainter {
  _Spotlight({required this.hole, required this.pulse});

  final Rect? hole;
  final double pulse;

  /// 外側の暗さ。ここが薄いと、穴を開けても差が出ない。
  static const Color _shade = Color(0xE60A050B);

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Offset.zero & size;
    final shade = Paint()..color = _shade;

    if (hole == null) {
      canvas.drawRect(screen, shade);
      return;
    }

    final rrect = RRect.fromRectAndRadius(hole!, const Radius.circular(14));

    // 一枚のレイヤーに暗幕を塗ってから、指した場所だけ消す。
    //
    // Path.combine で穴を開けていたが、web では効かず暗幕ごと消えていた。
    // 枠だけが浮いて、肝心の中身は暗いままだった。
    canvas.saveLayer(screen, Paint());
    canvas.drawRect(screen, shade);
    canvas.drawRRect(rrect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // 穴の中に光を足す。コインの丸のように、部品そのものが暗い場所がある。
    // 暗幕をどけるだけでは読めないので、明るさを持ち込む。
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Color.lerp(
          const Color(0x1FFFF0F6),
          const Color(0x33FFF0F6),
          pulse,
        )!,
    );

    // 枠を脈打たせる。暗いだけだと、どこが穴なのか分かりにくい。
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.rose.withValues(alpha: 0.55 + 0.45 * pulse),
    );
    canvas.drawRRect(
      rrect.inflate(4 + 4 * pulse),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.rose.withValues(alpha: 0.3 * (1 - pulse)),
    );
  }

  @override
  bool shouldRepaint(_Spotlight old) => old.hole != hole || old.pulse != pulse;
}

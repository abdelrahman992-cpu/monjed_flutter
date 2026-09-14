import 'package:flutter/material.dart';
import '../../controllers/reports_controller.dart';
import '../../widgets/monjed_ui.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _controller = ReportsController();
  final _text = TextEditingController();
  final _zone = TextEditingController(text: 'EG');
  final _location = TextEditingController();
  bool _busy = false;
  Map<String, dynamic>? _analysis;

  @override void dispose() { _text.dispose(); _zone.dispose(); _location.dispose(); super.dispose(); }

  Future<void> _analyzeAndSubmit() async {
    if (_text.text.trim().isEmpty || _zone.text.trim().isEmpty) {
      _snack('Describe the problem and choose a zone.'); return;
    }
    setState(() => _busy = true);
    try {
      final result = await _controller.analyzeReport({'report_text': _text.text.trim(), 'zone_id': _zone.text.trim(), 'location': _location.text.trim()});
      if (result is Map) setState(() => _analysis = Map<String, dynamic>.from(result));
      final submit = await _controller.submitReport({'report_text': _text.text.trim(), 'zone_id': _zone.text.trim(), 'location': _location.text.trim(), 'analysis': result});
      if (!mounted) return;
      _snack('Report submitted successfully.', ok: true);
      _text.clear();
    } catch (e) { if (mounted) _snack(e.toString()); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _snack(String text, {bool ok = false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: ok ? MonjedColors.green : null));

  @override
  Widget build(BuildContext context) => MonjedShell(
        title: 'Report a problem',
        eyebrow: 'COMMUNITY REPORT',
        showBack: true,
        child: LayoutBuilder(builder: (context, c) {
          final form = MonjedCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tell MONJED what is happening', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: MonjedColors.ink)),
            const SizedBox(height: 7),
            const Text('Your report can be analyzed and routed to the response team.', style: TextStyle(color: MonjedColors.muted, fontSize: 13)),
            const SizedBox(height: 22),
            _label('Zone ID'), TextField(controller: _zone, decoration: monjedInput('EG')),
            const SizedBox(height: 15), _label('Location'), TextField(controller: _location, decoration: monjedInput('City, street or landmark')),
            const SizedBox(height: 15), _label('What happened?'), TextField(controller: _text, minLines: 7, maxLines: 10, decoration: monjedInput('Describe flooding, earthquake damage, blocked roads, people needing help…')),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _busy ? null : _analyzeAndSubmit, style: ElevatedButton.styleFrom(backgroundColor: MonjedColors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))), child: _busy ? const SizedBox(height: 19, width: 19, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Analyze & submit report'))),
          ]));
          final analysis = MonjedCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Report analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 14), if (_analysis == null) const Text('Analysis will appear here after submission.', style: TextStyle(color: MonjedColors.muted, fontSize: 13)) else ..._analysis!.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(e.key.replaceAll('_', ' '), style: const TextStyle(color: MonjedColors.muted, fontSize: 12))), Expanded(child: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w700)))]))) ]));
          return c.maxWidth > 850 ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: form), const SizedBox(width: 22), SizedBox(width: 360, child: analysis)]) : Column(children: [form, const SizedBox(height: 18), analysis]);
        }),
      );

  Widget _label(String s) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text(s, style: const TextStyle(fontSize: 10, color: MonjedColors.muted, fontWeight: FontWeight.w700, letterSpacing: 1.1)));
}

import 'package:flutter/material.dart';
import '../../controllers/assistance_controller.dart';
import '../../widgets/monjed_ui.dart';

class AssistanceScreen extends StatefulWidget {
  const AssistanceScreen({super.key});
  @override State<AssistanceScreen> createState() => _AssistanceScreenState();
}

class _AssistanceScreenState extends State<AssistanceScreen> {
  final _controller = AssistanceController();
  final _type = TextEditingController(text: 'Emergency assistance');
  final _zone = TextEditingController(text: 'EG');
  final _location = TextEditingController();
  final _details = TextEditingController();
  bool _busy = false;

  @override void dispose() { _type.dispose(); _zone.dispose(); _location.dispose(); _details.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_details.text.trim().isEmpty) { _snack('Please describe the help you need.'); return; }
    setState(() => _busy = true);
    try {
      await _controller.createRequest({'request_type': _type.text.trim(), 'zone': _zone.text.trim(), 'country': 'EG', 'location': _location.text.trim(), 'description': _details.text.trim(), 'priority': 'high'});
      if (!mounted) return; _details.clear(); _snack('Your help request was sent.', ok: true);
    } catch (e) { if (mounted) _snack(e.toString()); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  void _snack(String s, {bool ok=false}) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s), backgroundColor: ok ? MonjedColors.green : null));

  @override Widget build(BuildContext context) => MonjedShell(title: 'Request help', eyebrow: 'EMERGENCY ASSISTANCE', showBack: true, child: LayoutBuilder(builder: (context,c) {
    final form = MonjedCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Request assistance', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      const SizedBox(height: 7), const Text('Send your location and what you need. A volunteer or response team can follow up.', style: TextStyle(color: MonjedColors.muted, fontSize: 13, height: 1.45)), const SizedBox(height: 22),
      _label('REQUEST TYPE'), TextField(controller: _type, decoration: monjedInput('Emergency assistance')), const SizedBox(height: 15),
      _label('ZONE ID'), TextField(controller: _zone, decoration: monjedInput('EG')), const SizedBox(height: 15),
      _label('LOCATION'), TextField(controller: _location, decoration: monjedInput('Address or landmark')), const SizedBox(height: 15),
      _label('WHAT DO YOU NEED?'), TextField(controller: _details, minLines: 6, maxLines: 9, decoration: monjedInput('People trapped, medical help, transport, evacuation…')), const SizedBox(height: 18),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _busy ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: MonjedColors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))), child: _busy ? const SizedBox(width:19,height:19,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Text('Request help')))
    ]));
    final info = MonjedCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.support_agent_outlined, color: MonjedColors.blue, size: 28), const SizedBox(height: 13), const Text('How it works', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 13), _step('1','Submit your request'), _step('2','MONJED matches available help'), _step('3','Track the response status'), const SizedBox(height: 12), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: MonjedColors.greenSoft,borderRadius: BorderRadius.circular(8)), child: const Text('If you are in immediate danger, contact local emergency services first.', style: TextStyle(color: Color(0xFF28766D), fontSize: 12, height: 1.4))) ]));
    return c.maxWidth>850 ? Row(crossAxisAlignment: CrossAxisAlignment.start, children:[Expanded(child:form),const SizedBox(width:22),SizedBox(width:360,child:info)]) : Column(children:[form,const SizedBox(height:18),info]);
  }));
  Widget _label(String s)=>Padding(padding:const EdgeInsets.only(bottom:7),child:Text(s,style:const TextStyle(fontSize:10,color:MonjedColors.muted,fontWeight:FontWeight.w700,letterSpacing:1.1)));
  Widget _step(String n,String text)=>Padding(padding:const EdgeInsets.only(bottom:14),child:Row(children:[Container(width:25,height:25,alignment:Alignment.center,decoration:BoxDecoration(color:MonjedColors.blueSoft,shape:BoxShape.circle),child:Text(n,style:const TextStyle(color:MonjedColors.blue,fontWeight:FontWeight.w800,fontSize:11))),const SizedBox(width:10),Expanded(child:Text(text,style:const TextStyle(fontSize:13,color:MonjedColors.ink)))]));
}

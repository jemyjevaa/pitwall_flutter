import 'package:flutter/cupertino.dart';
import 'package:pitbus_app/services/RequestServ.dart';
import 'package:pitbus_app/services/context_app.dart';
import '../models/job_appointment_model.dart';

class JobValidateViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoad = false;
  
  List<JobValidateModel> _jobs = [];
  List<JobValidateModel> get jobs => _jobs;

  RequestServ serv = RequestServ.instance;

  Future<void> fetchGetJobByAppointment(int idAppointment) async {

    if( _isLoad ) return;

    _isLoading = true;
    notifyListeners();

    try {
      print("Fetching job for appointment: $idAppointment");

      ResponseJobCite? responseJob = await serv.handlingRequestParsed(
        urlParam: "/api/appPitwall/citas",
        method: "GET",
        params: {
          "action" : "getDetailReport",
          "id" : "$idAppointment"
        },
        fromJson: (json) => ResponseJobCite.fromJson(json)
      );

      print(" [ responseJob ] => $responseJob");

      if (responseJob != null) {
        _jobs = responseJob.data.map((element) => JobValidateModel(
          id: element.id,
          idPreOdt: element.idPreOdt,
          // Parsing usuarioValida safely as it is dynamic in JobAppointmentModel
          id_usuario_valida: ContextApp().idUser,
          descripcion: element.descripcion,
          status: element.status,
        )).toList();
      } else {
        _jobs = [];
      }

      _jobs.forEach( ( things ) => print("[ JOB ] => ${things.descripcion}") );
      notifyListeners();

    } catch (e) {
      print("[ ERROR JobValidateViewModel ] fetchGetJobByAppointment => $e");
    } finally {
      _isLoad = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateJobStatus(int id, String newStatus) {
    final index = _jobs.indexWhere((job) => job.id == id);

    if (index != -1) {
      _jobs[index].status = newStatus;
      notifyListeners();
    }
  }

  Future<void> sendValidateJobs() async {
    //things.status

    List<dynamic> params = [];
    _jobs.forEach((things)
    {
      int status = switch( things.status ) {
        "Aceptada" => 1,
        _ => 2
      };
      params.add({
        "id" : things.id,
        "id_valida_usuario" : ContextApp().idUser,
        "status" : "$status"
      });
      // print("[ sendValidateJobs ]=>{"
      //   "id : ${things.id},"
      //   "id_valida_usuario : ${ContextApp().idUser},"
      //   "status : $status,"
      //   "}");
    }
    );
    try{

      final responseJob = await serv.handlingRequestParsed(
          urlParam: "/api/appPitwall/citas/",
          method: "POST",
          params: {
            "action" : "qualify",
            "fails": params.toList()
          },
          fromJson: (json) => json
      );

      print("responseJob => $responseJob");

    }catch(e){
      print("[ ERROR JobValidateViewModel ] sendValidateJobs => $e");
    }
  }


}

class JobValidateModel {
  final int id;
  final int idPreOdt;
  final int id_usuario_valida;
  final String descripcion;
  String status;

  JobValidateModel({
    required this.id,
    required this.idPreOdt,
    required this.id_usuario_valida,
    required this.descripcion,
    required this.status,
  });
}

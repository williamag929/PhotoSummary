
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/project.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  Project? _currentProject;

  List<Project> get projects => _projects;
  Project? get currentProject => _currentProject;

  Future<void> fetchProjects() async {
    final List<Map<String, dynamic>> projectMaps = await DatabaseHelper.instance.getProjects();
    _projects = projectMaps.map((projectMap) => Project.fromMap(projectMap)).toList();
    if (_projects.isNotEmpty) {
      _currentProject = _projects.first;
    }
    notifyListeners();
  }

  Future<void> addProject(String name) async {
    final newProject = Project(name: name);
    await DatabaseHelper.instance.insertProject(newProject.toMap());
    await fetchProjects();
  }

  void switchProject(Project project) {
    _currentProject = project;
    notifyListeners();
  }
}

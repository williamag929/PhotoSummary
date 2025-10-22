import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch projects when the screen is initialized
    Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Projects'),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          if (projectProvider.projects.isEmpty) {
            return const Center(
              child: Text('No projects found. Add a new one!'),
            );
          }
          return ListView.builder(
            itemCount: projectProvider.projects.length,
            itemBuilder: (context, index) {
              final project = projectProvider.projects[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(project.name),
                  subtitle: Text('${project.company ?? ''} - ${project.address ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showProjectFormDialog(project),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmationDialog(project.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProjectFormDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showProjectFormDialog(Project? project) async {
    final result = await showDialog<Project>(
      context: context,
      builder: (context) => _ProjectFormDialog(project: project),
    );

    if (result != null) {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      if (project == null) {
        await projectProvider.addProject(result);
      } else {
        await projectProvider.updateProject(result);
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog(int projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Provider.of<ProjectProvider>(context, listen: false).deleteProject(projectId);
    }
  }
}

class _ProjectFormDialog extends StatefulWidget {
  final Project? project;

  const _ProjectFormDialog({this.project});

  @override
  State<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<_ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _company;
  late String _address;
  late String _zipcode;

  @override
  void initState() {
    super.initState();
    _name = widget.project?.name ?? '';
    _company = widget.project?.company ?? '';
    _address = widget.project?.address ?? '';
    _zipcode = widget.project?.zipcode ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.project == null ? 'Add Project' : 'Edit Project'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _company,
                decoration: const InputDecoration(labelText: 'Company'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a company';
                  }
                  return null;
                },
                onSaved: (value) => _company = value!,
              ),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) => _address = value!,
              ),
              TextFormField(
                initialValue: _zipcode,
                decoration: const InputDecoration(labelText: 'Zipcode'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a zipcode';
                  }
                  return null;
                },
                onSaved: (value) => _zipcode = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final project = Project(
                id: widget.project?.id,
                name: _name,
                company: _company,
                address: _address,
                zipcode: _zipcode,
              );
              Navigator.of(context).pop(project);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

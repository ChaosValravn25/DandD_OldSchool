// lib/pages/bestiary/monster_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/monster.dart';
import '../../providers/monster_provider.dart';

class MonsterFormPage extends StatefulWidget {
  final Monster? monster; // null = crear, != null = editar
  
  const MonsterFormPage({super.key, this.monster});

  @override
  State<MonsterFormPage> createState() => _MonsterFormPageState();
}

class _MonsterFormPageState extends State<MonsterFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _abilitiesController;
  late TextEditingController _hpController;
  late TextEditingController _acController;
  
  String _selectedEdition = 'OD&D';
  String _selectedType = 'Humanoid';
  String _selectedSize = 'Medium';
  
  final List<String> _editions = ['OD&D', 'AD&D 1e', 'AD&D 2e', '3e', '3.5e'];
  final List<String> _types = ['Humanoid', 'Undead', 'Beast', 'Dragon', 'Aberration', 'Ooze', 'Construct', 'Elemental', 'Fey', 'Giant', 'Magical Beast', 'Plant'];
  final List<String> _sizes = ['Tiny', 'Small', 'Medium', 'Large', 'Huge', 'Gargantuan'];

  @override
  void initState() {
    super.initState();
    final m = widget.monster;
    
    _nameController = TextEditingController(text: m?.name ?? '');
    _descriptionController = TextEditingController(text: m?.description ?? '');
    _abilitiesController = TextEditingController(text: m?.abilities ?? '');
    _hpController = TextEditingController(text: m?.hp.toString() ?? '');
    _acController = TextEditingController(text: m?.ac?.toString() ?? '');
    
    if (m != null) {
      _selectedEdition = m.edition;
      _selectedType = m.type ?? 'Humanoid';
      _selectedSize = m.size ?? 'Medium';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _abilitiesController.dispose();
    _hpController.dispose();
    _acController.dispose();
    super.dispose();
  }

  Future<void> _saveMonster() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<MonsterProvider>(context, listen: false);
    
    final monster = Monster(
      id: widget.monster?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      edition: _selectedEdition,
      type: _selectedType,
      size: _selectedSize,
      hp: int.parse(_hpController.text.trim()),
      ac: _acController.text.isNotEmpty ? int.parse(_acController.text.trim()) : null,
      description: _descriptionController.text.trim(),
      abilities: _abilitiesController.text.trim().isNotEmpty ? _abilitiesController.text.trim() : null,
      imagePath: widget.monster?.imagePath,
      isFavorite: widget.monster?.isFavorite ?? false,
      createdAt: widget.monster?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (widget.monster == null) {
      success = await provider.addMonster(monster);
    } else {
      success = await provider.updateMonster(monster);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.monster == null ? 'Monstruo agregado' : 'Monstruo actualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.monster == null ? 'Nuevo Monstruo' : 'Editar Monstruo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMonster,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                hintText: 'Ej: Beholder',
                prefixIcon: Icon(Icons.pets),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedEdition,
              decoration: const InputDecoration(
                labelText: 'Edición *',
                prefixIcon: Icon(Icons.history_edu),
              ),
              items: _editions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => _selectedEdition = value!),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                prefixIcon: Icon(Icons.category),
              ),
              items: _types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedSize,
              decoration: const InputDecoration(
                labelText: 'Tamaño',
                prefixIcon: Icon(Icons.photo_size_select_small),
              ),
              items: _sizes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => _selectedSize = value!),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hpController,
                    decoration: const InputDecoration(
                      labelText: 'HP *',
                      prefixIcon: Icon(Icons.favorite),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _acController,
                    decoration: const InputDecoration(
                      labelText: 'AC',
                      prefixIcon: Icon(Icons.shield),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                hintText: 'Descripción del monstruo',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _abilitiesController,
              decoration: const InputDecoration(
                labelText: 'Habilidades',
                hintText: 'Habilidades especiales del monstruo',
                prefixIcon: Icon(Icons.bolt),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: _saveMonster,
              icon: const Icon(Icons.save),
              label: Text(widget.monster == null ? 'Crear Monstruo' : 'Guardar Cambios'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
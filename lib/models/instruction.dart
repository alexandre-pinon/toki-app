class Instruction {
  final String id;
  final String recipeId;
  final int stepNumber;
  final String instruction;

  Instruction(this.id, this.recipeId, this.stepNumber, this.instruction);

  Instruction.fromJson(dynamic json)
      : id = json['id'],
        recipeId = json['recipe_id'],
        stepNumber = json['step_number'],
        instruction = json['instruction'];
}

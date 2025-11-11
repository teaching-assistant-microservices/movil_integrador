class ChatRequestDto {
  final String userId;
  final String query; // El mensaje del usuario (local)
  final String? conversationId; // ID de sesión (local)
  
  // Agregar campos con sus valores por defecto de FastAPI
  final bool useHistory; 
  final int maxHistory;   
  final int topK;         

  ChatRequestDto({
    required this.userId,
    required this.query,
    this.conversationId,
    // Coincidir con los valores por defecto de FastAPI
    this.useHistory = true, 
    this.maxHistory = 5,
    this.topK = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      // **CORRECCIÓN 1: Usar nombres esperados por FastAPI**
      'user_id': userId,
      'message': query, // Debe ser 'message', no 'query'
      // Debe ser 'session_id', no 'conversation_id'
      if (conversationId != null) 'session_id': conversationId, 

      // **CORRECCIÓN 2: Incluir todos los campos**
      'use_history': useHistory,
      'max_history': maxHistory,
      'top_k': topK,
    };
  }
}
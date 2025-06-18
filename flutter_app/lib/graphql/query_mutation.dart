// lib/graphql/query_mutation.dart

// User Mutations
const String registerMutation = r'''
  mutation Register($name: String!, $email: String!, $password: String!) {
    register(name: $name, email: $email, password: $password) {
      token
      user {
        id
        name
        email
      }
    }
  }
''';

const String loginMutation = r'''
  mutation Login($email: String!, $password: String!) {
    login(email: $email, password: $password) {
      token
      user {
        id
        name
        email
      }
    }
  }
''';

// User Queries (e.g., Me query)
const String meQuery = r'''
  query Me {
    me {
      id
      name
      email
    }
  }
''';

// Note Queries
const String allNotesQuery = r'''
  query Notes {
    notes {
      id
      title
      content
      isFavorite
      createdAt
      updatedAt
      reminderTime # Pastikan ini ada
      user {
        id
        name
        email
      }
      category {
        id
        name
      }
    }
  }
''';

const String notesByCategoryQuery = r'''
  query NotesByCategory($idCategory: ID!) {
    notesByCategory(idCategory: $idCategory) {
      id
      title
      content
      isFavorite
      createdAt
      updatedAt
      reminderTime # Tambahkan ini jika ingin filter/tampilkan berdasarkan kategori
      user {
        id
        name
        email
      }
      category {
        id
        name
      }
    }
  }
''';

const String favoriteNotesQuery = r'''
  query FavoriteNotes {
    favoriteNotes {
      id
      title
      content
      isFavorite
      createdAt
      updatedAt
      reminderTime # Tambahkan ini jika ingin filter/tampilkan favorit
      user {
        id
        name
        email
      }
      category {
        id
        name
      }
    }
  }
''';

// Note Mutations
const String createNoteMutation = r'''
  mutation CreateNote($title: String!, $content: String!, $isFavorite: Boolean!, $createdBy: ID!, $idCategory: ID!, $reminderTime: String) {
    createNote(title: $title, content: $content, isFavorite: $isFavorite, createdBy: $createdBy, idCategory: $idCategory, reminderTime: $reminderTime) {
      id
      title
      content
      isFavorite
      createdAt
      updatedAt
      reminderTime # Pastikan ini ada di respons
      user {
        id
        name
        email
      }
      category {
        id
        name
      }
    }
  }
''';

const String updateNoteMutation = r'''
  mutation UpdateNote($id: Int!, $title: String, $content: String, $isFavorite: Boolean, $idCategory: ID, $reminderTime: String) {
    updateNote(id: $id, title: $title, content: $content, isFavorite: $isFavorite, idCategory: $idCategory, reminderTime: $reminderTime) {
      id
      title
      content
      isFavorite
      createdAt
      updatedAt
      reminderTime # Pastikan ini ada di respons
      user {
        id
        name
        email
      }
      category {
        id
        name
      }
    }
  }
''';

const String deleteNoteMutation = r'''
  mutation DeleteNote($id: Int!) {
    deleteNote(id: $id)
  }
''';

// Category Queries
const String allCategoriesQuery = r'''
  query Categories {
    categories {
      id
      name
    }
  }
''';

const String categoryByIdQuery = r'''
  query Category($id: Int!) {
    category(id: $id) {
      id
      name
    }
  }
''';

const String tableName = "articles";

const String idField = "_id";
const String titleField = "title";
const String contentField = "content";
const String creationDateField = "date_of_creation";
const String lastEditField = "date_of_editing";
const String isVisibleField = "is_visible";

const String authorIdField = "_authorid";

const List<String> articleColumn = [
  idField,
  titleField,
  contentField,
  creationDateField,
  lastEditField,
  isVisibleField,
];

const String boolType = "BOOLEAN NOT NULL";
const String idType = "INTEGER PRIMARY KEY AUTO INCREMENT";
const String idTypeNullable = "INTEGER NOT NULL";
const String textTypeNullable = "TEXT";
const String textType = "TEXT NOT NULL";

const String createArticleTable = '''
  CREATE TABLE $tableName (
    $idField $idType,
    $titleField $textType,
    $contentField $textTypeNullable,
    $creationDateField $textType,
    $lastEditField $textType,
    $isVisibleField $boolType,
    $authorIdField $idType
  )
  ''';

class Articles {

  final int? id;
  final String title;
  final int authorId;
  final String? content;
  final DateTime creationDate;
  final DateTime lastEdit;
  final bool isVisible;

  const Articles({
    this.id,
    required this.title,
    required this.authorId,
    this.content,
    required this.creationDate,
    required this.lastEdit,
    required this.isVisible,
  });

  factory Articles.fromJson(Map<String, dynamic> json) => Articles(
    id: json[idField] as int?,
    title: json[titleField] as String,
    authorId: json[authorIdField] as int,
    content: json[contentField] as String?,
    creationDate: DateTime.parse(json[creationDateField] as String ),
    lastEdit: DateTime.parse(json[lastEditField] as String),
    isVisible: json[isVisibleField] == 1
  );

  Map<String, dynamic> toJson() => {
    idField: id,
    titleField: title,
    authorIdField: authorId,
    contentField: content,
    creationDateField: creationDate,
    lastEditField: lastEdit,
    isVisibleField: isVisible ? 1 : 0,
  };

  Articles copyWith({
    int? id,
    String? title,
    int? authorId,
    String? content,
    DateTime? creationDate,
    DateTime? lastEdit,
    bool? isVisible,
  }) =>
      Articles(
        id: id ?? this.id,
        title: title ?? this.title,
        authorId: authorId ?? this.authorId,
        content: content ?? this.content,
        creationDate: creationDate ?? this.creationDate,
        lastEdit: lastEdit ?? this.lastEdit,
        isVisible: isVisible ?? this.isVisible,
      );

}
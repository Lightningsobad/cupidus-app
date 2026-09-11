// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cupid_database.dart';

// ignore_for_file: type=lint
class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receiverIdMeta = const VerificationMeta(
    'receiverId',
  );
  @override
  late final GeneratedColumn<String> receiverId = GeneratedColumn<String>(
    'receiver_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    senderId,
    receiverId,
    content,
    type,
    status,
    readAt,
    createdAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('receiver_id')) {
      context.handle(
        _receiverIdMeta,
        receiverId.isAcceptableOrUnknown(data['receiver_id']!, _receiverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_receiverIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      receiverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receiver_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String type;
  final String status;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime cachedAt;
  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.status,
    this.readAt,
    required this.createdAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sender_id'] = Variable<String>(senderId);
    map['receiver_id'] = Variable<String>(receiverId);
    map['content'] = Variable<String>(content);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      senderId: Value(senderId),
      receiverId: Value(receiverId),
      content: Value(content),
      type: Value(type),
      status: Value(status),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      createdAt: Value(createdAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      senderId: serializer.fromJson<String>(json['senderId']),
      receiverId: serializer.fromJson<String>(json['receiverId']),
      content: serializer.fromJson<String>(json['content']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'senderId': serializer.toJson<String>(senderId),
      'receiverId': serializer.toJson<String>(receiverId),
      'content': serializer.toJson<String>(content),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    String? type,
    String? status,
    Value<DateTime?> readAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? cachedAt,
  }) => Message(
    id: id ?? this.id,
    senderId: senderId ?? this.senderId,
    receiverId: receiverId ?? this.receiverId,
    content: content ?? this.content,
    type: type ?? this.type,
    status: status ?? this.status,
    readAt: readAt.present ? readAt.value : this.readAt,
    createdAt: createdAt ?? this.createdAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      receiverId: data.receiverId.present
          ? data.receiverId.value
          : this.receiverId,
      content: data.content.present ? data.content.value : this.content,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('senderId: $senderId, ')
          ..write('receiverId: $receiverId, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    senderId,
    receiverId,
    content,
    type,
    status,
    readAt,
    createdAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.senderId == this.senderId &&
          other.receiverId == this.receiverId &&
          other.content == this.content &&
          other.type == this.type &&
          other.status == this.status &&
          other.readAt == this.readAt &&
          other.createdAt == this.createdAt &&
          other.cachedAt == this.cachedAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> senderId;
  final Value<String> receiverId;
  final Value<String> content;
  final Value<String> type;
  final Value<String> status;
  final Value<DateTime?> readAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.senderId = const Value.absent(),
    this.receiverId = const Value.absent(),
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.readAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String senderId,
    required String receiverId,
    required String content,
    required String type,
    required String status,
    this.readAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       senderId = Value(senderId),
       receiverId = Value(receiverId),
       content = Value(content),
       type = Value(type),
       status = Value(status),
       createdAt = Value(createdAt),
       cachedAt = Value(cachedAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? senderId,
    Expression<String>? receiverId,
    Expression<String>? content,
    Expression<String>? type,
    Expression<String>? status,
    Expression<DateTime>? readAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (senderId != null) 'sender_id': senderId,
      if (receiverId != null) 'receiver_id': receiverId,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (readAt != null) 'read_at': readAt,
      if (createdAt != null) 'created_at': createdAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? senderId,
    Value<String>? receiverId,
    Value<String>? content,
    Value<String>? type,
    Value<String>? status,
    Value<DateTime?>? readAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (receiverId.present) {
      map['receiver_id'] = Variable<String>(receiverId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('senderId: $senderId, ')
          ..write('receiverId: $receiverId, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimelineEntriesTable extends TimelineEntries
    with TableInfo<$TimelineEntriesTable, TimelineEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    description,
    photoUrl,
    icon,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimelineEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TimelineEntriesTable createAlias(String alias) {
    return $TimelineEntriesTable(attachedDatabase, alias);
  }
}

class TimelineEntry extends DataClass implements Insertable<TimelineEntry> {
  final String id;
  final String type;
  final String title;
  final String? description;
  final String? photoUrl;
  final String? icon;
  final DateTime createdAt;
  const TimelineEntry({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.photoUrl,
    this.icon,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TimelineEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimelineEntriesCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      createdAt: Value(createdAt),
    );
  }

  factory TimelineEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineEntry(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      icon: serializer.fromJson<String?>(json['icon']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'icon': serializer.toJson<String?>(icon),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TimelineEntry copyWith({
    String? id,
    String? type,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    DateTime? createdAt,
  }) => TimelineEntry(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    icon: icon.present ? icon.value : this.icon,
    createdAt: createdAt ?? this.createdAt,
  );
  TimelineEntry copyWithCompanion(TimelineEntriesCompanion data) {
    return TimelineEntry(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      icon: data.icon.present ? data.icon.value : this.icon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEntry(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, title, description, photoUrl, icon, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineEntry &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.description == this.description &&
          other.photoUrl == this.photoUrl &&
          other.icon == this.icon &&
          other.createdAt == this.createdAt);
}

class TimelineEntriesCompanion extends UpdateCompanion<TimelineEntry> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> photoUrl;
  final Value<String?> icon;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TimelineEntriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.icon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimelineEntriesCompanion.insert({
    required String id,
    required String type,
    required String title,
    this.description = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.icon = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<TimelineEntry> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? photoUrl,
    Expression<String>? icon,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (icon != null) 'icon': icon,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimelineEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? photoUrl,
    Value<String?>? icon,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TimelineEntriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEntriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('icon: $icon, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimelineSyncStateTable extends TimelineSyncState
    with TableInfo<$TimelineSyncStateTable, TimelineSyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineSyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineSyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimelineSyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineSyncStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $TimelineSyncStateTable createAlias(String alias) {
    return $TimelineSyncStateTable(attachedDatabase, alias);
  }
}

class TimelineSyncStateData extends DataClass
    implements Insertable<TimelineSyncStateData> {
  final int id;
  final DateTime? lastSyncedAt;
  const TimelineSyncStateData({required this.id, this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  TimelineSyncStateCompanion toCompanion(bool nullToAbsent) {
    return TimelineSyncStateCompanion(
      id: Value(id),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory TimelineSyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineSyncStateData(
      id: serializer.fromJson<int>(json['id']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  TimelineSyncStateData copyWith({
    int? id,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => TimelineSyncStateData(
    id: id ?? this.id,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  TimelineSyncStateData copyWithCompanion(TimelineSyncStateCompanion data) {
    return TimelineSyncStateData(
      id: data.id.present ? data.id.value : this.id,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineSyncStateData(')
          ..write('id: $id, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineSyncStateData &&
          other.id == this.id &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class TimelineSyncStateCompanion
    extends UpdateCompanion<TimelineSyncStateData> {
  final Value<int> id;
  final Value<DateTime?> lastSyncedAt;
  const TimelineSyncStateCompanion({
    this.id = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  TimelineSyncStateCompanion.insert({
    this.id = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  static Insertable<TimelineSyncStateData> custom({
    Expression<int>? id,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  TimelineSyncStateCompanion copyWith({
    Value<int>? id,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return TimelineSyncStateCompanion(
      id: id ?? this.id,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineSyncStateCompanion(')
          ..write('id: $id, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    category,
    amount,
    description,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCacheRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class ExpenseCacheRow extends DataClass implements Insertable<ExpenseCacheRow> {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime createdAt;
  const ExpenseCacheRow({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      userId: Value(userId),
      category: Value(category),
      amount: Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory ExpenseCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCacheRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String?>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String?>(description),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ExpenseCacheRow copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    Value<String?> description = const Value.absent(),
    DateTime? date,
    DateTime? createdAt,
  }) => ExpenseCacheRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    description: description.present ? description.value : this.description,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
  ExpenseCacheRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseCacheRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      description: data.description.present
          ? data.description.value
          : this.description,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCacheRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, category, amount, description, date, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCacheRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseCacheRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> category;
  final Value<double> amount;
  final Value<String?> description;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String userId,
    required String category,
    required double amount,
    this.description = const Value.absent(),
    required DateTime date,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       category = Value(category),
       amount = Value(amount),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<ExpenseCacheRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? category,
    Value<double>? amount,
    Value<String?>? description,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseSyncMetadataTable extends ExpenseSyncMetadata
    with TableInfo<$ExpenseSyncMetadataTable, ExpenseSyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseSyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSuccessfulSyncAtMeta =
      const VerificationMeta('lastSuccessfulSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSuccessfulSyncAt =
      GeneratedColumn<DateTime>(
        'last_successful_sync_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [id, lastSuccessfulSyncAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseSyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_successful_sync_at')) {
      context.handle(
        _lastSuccessfulSyncAtMeta,
        lastSuccessfulSyncAt.isAcceptableOrUnknown(
          data['last_successful_sync_at']!,
          _lastSuccessfulSyncAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseSyncMetadataData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseSyncMetadataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastSuccessfulSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_successful_sync_at'],
      ),
    );
  }

  @override
  $ExpenseSyncMetadataTable createAlias(String alias) {
    return $ExpenseSyncMetadataTable(attachedDatabase, alias);
  }
}

class ExpenseSyncMetadataData extends DataClass
    implements Insertable<ExpenseSyncMetadataData> {
  final int id;
  final DateTime? lastSuccessfulSyncAt;
  const ExpenseSyncMetadataData({required this.id, this.lastSuccessfulSyncAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastSuccessfulSyncAt != null) {
      map['last_successful_sync_at'] = Variable<DateTime>(lastSuccessfulSyncAt);
    }
    return map;
  }

  ExpenseSyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return ExpenseSyncMetadataCompanion(
      id: Value(id),
      lastSuccessfulSyncAt: lastSuccessfulSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessfulSyncAt),
    );
  }

  factory ExpenseSyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseSyncMetadataData(
      id: serializer.fromJson<int>(json['id']),
      lastSuccessfulSyncAt: serializer.fromJson<DateTime?>(
        json['lastSuccessfulSyncAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastSuccessfulSyncAt': serializer.toJson<DateTime?>(
        lastSuccessfulSyncAt,
      ),
    };
  }

  ExpenseSyncMetadataData copyWith({
    int? id,
    Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
  }) => ExpenseSyncMetadataData(
    id: id ?? this.id,
    lastSuccessfulSyncAt: lastSuccessfulSyncAt.present
        ? lastSuccessfulSyncAt.value
        : this.lastSuccessfulSyncAt,
  );
  ExpenseSyncMetadataData copyWithCompanion(ExpenseSyncMetadataCompanion data) {
    return ExpenseSyncMetadataData(
      id: data.id.present ? data.id.value : this.id,
      lastSuccessfulSyncAt: data.lastSuccessfulSyncAt.present
          ? data.lastSuccessfulSyncAt.value
          : this.lastSuccessfulSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseSyncMetadataData(')
          ..write('id: $id, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastSuccessfulSyncAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseSyncMetadataData &&
          other.id == this.id &&
          other.lastSuccessfulSyncAt == this.lastSuccessfulSyncAt);
}

class ExpenseSyncMetadataCompanion
    extends UpdateCompanion<ExpenseSyncMetadataData> {
  final Value<int> id;
  final Value<DateTime?> lastSuccessfulSyncAt;
  const ExpenseSyncMetadataCompanion({
    this.id = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
  });
  ExpenseSyncMetadataCompanion.insert({
    this.id = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
  });
  static Insertable<ExpenseSyncMetadataData> custom({
    Expression<int>? id,
    Expression<DateTime>? lastSuccessfulSyncAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastSuccessfulSyncAt != null)
        'last_successful_sync_at': lastSuccessfulSyncAt,
    });
  }

  ExpenseSyncMetadataCompanion copyWith({
    Value<int>? id,
    Value<DateTime?>? lastSuccessfulSyncAt,
  }) {
    return ExpenseSyncMetadataCompanion(
      id: id ?? this.id,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastSuccessfulSyncAt.present) {
      map['last_successful_sync_at'] = Variable<DateTime>(
        lastSuccessfulSyncAt.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseSyncMetadataCompanion(')
          ..write('id: $id, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt')
          ..write(')'))
        .toString();
  }
}

class $ActivityCardsTable extends ActivityCards
    with TableInfo<$ActivityCardsTable, ActivityCardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerKeyMeta = const VerificationMeta(
    'ownerKey',
  );
  @override
  late final GeneratedColumn<String> ownerKey = GeneratedColumn<String>(
    'owner_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('idea'),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityType?, String>
  activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<ActivityType?>($ActivityCardsTable.$converteractivityType);
  static const VerificationMeta _scheduledOnMeta = const VerificationMeta(
    'scheduledOn',
  );
  @override
  late final GeneratedColumn<String> scheduledOn = GeneratedColumn<String>(
    'scheduled_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceVndMeta = const VerificationMeta(
    'priceVnd',
  );
  @override
  late final GeneratedColumn<int> priceVnd = GeneratedColumn<int>(
    'price_vnd',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsBookingMeta = const VerificationMeta(
    'needsBooking',
  );
  @override
  late final GeneratedColumn<bool> needsBooking = GeneratedColumn<bool>(
    'needs_booking',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_booking" IN (0, 1))',
    ),
  );
  static const VerificationMeta _indoorOutdoorMeta = const VerificationMeta(
    'indoorOutdoor',
  );
  @override
  late final GeneratedColumn<String> indoorOutdoor = GeneratedColumn<String>(
    'indoor_outdoor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceLinkMeta = const VerificationMeta(
    'sourceLink',
  );
  @override
  late final GeneratedColumn<String> sourceLink = GeneratedColumn<String>(
    'source_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invitedMeta = const VerificationMeta(
    'invited',
  );
  @override
  late final GeneratedColumn<bool> invited = GeneratedColumn<bool>(
    'invited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("invited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _replyStateMeta = const VerificationMeta(
    'replyState',
  );
  @override
  late final GeneratedColumn<String> replyState = GeneratedColumn<String>(
    'reply_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('not_answered'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TimeOfDaySlot?, String>
  timeOfDaySlot = GeneratedColumn<String>(
    'time_of_day_slot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<TimeOfDaySlot?>($ActivityCardsTable.$convertertimeOfDaySlot);
  static const VerificationMeta _noteKeywordsMeta = const VerificationMeta(
    'noteKeywords',
  );
  @override
  late final GeneratedColumn<String> noteKeywords = GeneratedColumn<String>(
    'note_keywords',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkSourceLabelMeta = const VerificationMeta(
    'linkSourceLabel',
  );
  @override
  late final GeneratedColumn<String> linkSourceLabel = GeneratedColumn<String>(
    'link_source_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkSavedAtMeta = const VerificationMeta(
    'linkSavedAt',
  );
  @override
  late final GeneratedColumn<int> linkSavedAt = GeneratedColumn<int>(
    'link_saved_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerKey,
    title,
    status,
    origin,
    activityType,
    scheduledOn,
    priceVnd,
    distanceKm,
    needsBooking,
    indoorOutdoor,
    note,
    sourceLink,
    invited,
    replyState,
    createdAt,
    updatedAt,
    durationMinutes,
    timeOfDaySlot,
    noteKeywords,
    linkSourceLabel,
    linkSavedAt,
    location,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityCardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_key')) {
      context.handle(
        _ownerKeyMeta,
        ownerKey.isAcceptableOrUnknown(data['owner_key']!, _ownerKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('scheduled_on')) {
      context.handle(
        _scheduledOnMeta,
        scheduledOn.isAcceptableOrUnknown(
          data['scheduled_on']!,
          _scheduledOnMeta,
        ),
      );
    }
    if (data.containsKey('price_vnd')) {
      context.handle(
        _priceVndMeta,
        priceVnd.isAcceptableOrUnknown(data['price_vnd']!, _priceVndMeta),
      );
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    }
    if (data.containsKey('needs_booking')) {
      context.handle(
        _needsBookingMeta,
        needsBooking.isAcceptableOrUnknown(
          data['needs_booking']!,
          _needsBookingMeta,
        ),
      );
    }
    if (data.containsKey('indoor_outdoor')) {
      context.handle(
        _indoorOutdoorMeta,
        indoorOutdoor.isAcceptableOrUnknown(
          data['indoor_outdoor']!,
          _indoorOutdoorMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source_link')) {
      context.handle(
        _sourceLinkMeta,
        sourceLink.isAcceptableOrUnknown(data['source_link']!, _sourceLinkMeta),
      );
    }
    if (data.containsKey('invited')) {
      context.handle(
        _invitedMeta,
        invited.isAcceptableOrUnknown(data['invited']!, _invitedMeta),
      );
    }
    if (data.containsKey('reply_state')) {
      context.handle(
        _replyStateMeta,
        replyState.isAcceptableOrUnknown(data['reply_state']!, _replyStateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('note_keywords')) {
      context.handle(
        _noteKeywordsMeta,
        noteKeywords.isAcceptableOrUnknown(
          data['note_keywords']!,
          _noteKeywordsMeta,
        ),
      );
    }
    if (data.containsKey('link_source_label')) {
      context.handle(
        _linkSourceLabelMeta,
        linkSourceLabel.isAcceptableOrUnknown(
          data['link_source_label']!,
          _linkSourceLabelMeta,
        ),
      );
    }
    if (data.containsKey('link_saved_at')) {
      context.handle(
        _linkSavedAtMeta,
        linkSavedAt.isAcceptableOrUnknown(
          data['link_saved_at']!,
          _linkSavedAtMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityCardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityCardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      activityType: $ActivityCardsTable.$converteractivityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activity_type'],
        ),
      ),
      scheduledOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduled_on'],
      ),
      priceVnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_vnd'],
      ),
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_km'],
      ),
      needsBooking: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_booking'],
      ),
      indoorOutdoor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}indoor_outdoor'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      sourceLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_link'],
      ),
      invited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}invited'],
      )!,
      replyState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
      timeOfDaySlot: $ActivityCardsTable.$convertertimeOfDaySlot.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}time_of_day_slot'],
        ),
      ),
      noteKeywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_keywords'],
      ),
      linkSourceLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link_source_label'],
      ),
      linkSavedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}link_saved_at'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
    );
  }

  @override
  $ActivityCardsTable createAlias(String alias) {
    return $ActivityCardsTable(attachedDatabase, alias);
  }

  static TypeConverter<ActivityType?, String?> $converteractivityType =
      const ActivityTypeConverter();
  static TypeConverter<TimeOfDaySlot?, String?> $convertertimeOfDaySlot =
      const TimeOfDaySlotConverter();
}

class ActivityCardRow extends DataClass implements Insertable<ActivityCardRow> {
  /// Client-generated UUID v4, permanently stable. Never a rowid/autoincrement
  /// (R-15a) — later stories reference cards by this id.
  final String id;

  /// Backend `User.id` of the session that created the card.
  final String ownerKey;

  /// The single mandatory user-supplied field (AC-6).
  final String title;

  /// One of `idea` | `scheduled` | `done` | `memory`.
  final String status;

  /// Internal provenance identifier; never rendered as a metric (AC-9).
  final String origin;
  final ActivityType? activityType;

  /// Civil date `YYYY-MM-DD` in the device calendar — deliberately not a
  /// DateTime/instant, so it never shifts with the host's UTC offset.
  final String? scheduledOn;
  final int? priceVnd;
  final double? distanceKm;

  /// Three-valued: null means "not known yet", not "false".
  final bool? needsBooking;
  final String? indoorOutdoor;
  final String? note;

  /// Raw URL as pasted by the user, kept verbatim (AC-7).
  final String? sourceLink;
  final bool invited;

  /// `not_answered` | `answered` (R-1b).
  final String replyState;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Duration in **minutes** (B-1). The Vietnamese display string ("2 tiếng")
  /// is produced by the presentation formatter; a formatted string must never
  /// reach this column.
  final int? durationMinutes;

  /// User-picked part of the day (B-1). Never inferred from [scheduledOn].
  final TimeOfDaySlot? timeOfDaySlot;

  /// Short keyword list (B-1), a sibling of [note] rather than a replacement:
  /// [note] keeps its free-text meaning and is never migrated into here.
  final String? noteKeywords;

  /// Display name of the source shown next to [sourceLink] (B-1). Not derived
  /// from the URL.
  final String? linkSourceLabel;

  /// When the user pasted the link (B-1). INTEGER, not a `DateTimeColumn`, per
  /// the settled table in `ux/uiux-spec.md` §8.
  final int? linkSavedAt;

  /// Free-text place as the user typed it (schema v5). Never geocoded, never
  /// resolved against a places API, and never split into structured parts: it
  /// is display text and the source of the `place` mad-libs variable (AC-4).
  final String? location;
  const ActivityCardRow({
    required this.id,
    required this.ownerKey,
    required this.title,
    required this.status,
    required this.origin,
    this.activityType,
    this.scheduledOn,
    this.priceVnd,
    this.distanceKm,
    this.needsBooking,
    this.indoorOutdoor,
    this.note,
    this.sourceLink,
    required this.invited,
    required this.replyState,
    required this.createdAt,
    required this.updatedAt,
    this.durationMinutes,
    this.timeOfDaySlot,
    this.noteKeywords,
    this.linkSourceLabel,
    this.linkSavedAt,
    this.location,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_key'] = Variable<String>(ownerKey);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || activityType != null) {
      map['activity_type'] = Variable<String>(
        $ActivityCardsTable.$converteractivityType.toSql(activityType),
      );
    }
    if (!nullToAbsent || scheduledOn != null) {
      map['scheduled_on'] = Variable<String>(scheduledOn);
    }
    if (!nullToAbsent || priceVnd != null) {
      map['price_vnd'] = Variable<int>(priceVnd);
    }
    if (!nullToAbsent || distanceKm != null) {
      map['distance_km'] = Variable<double>(distanceKm);
    }
    if (!nullToAbsent || needsBooking != null) {
      map['needs_booking'] = Variable<bool>(needsBooking);
    }
    if (!nullToAbsent || indoorOutdoor != null) {
      map['indoor_outdoor'] = Variable<String>(indoorOutdoor);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || sourceLink != null) {
      map['source_link'] = Variable<String>(sourceLink);
    }
    map['invited'] = Variable<bool>(invited);
    map['reply_state'] = Variable<String>(replyState);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || timeOfDaySlot != null) {
      map['time_of_day_slot'] = Variable<String>(
        $ActivityCardsTable.$convertertimeOfDaySlot.toSql(timeOfDaySlot),
      );
    }
    if (!nullToAbsent || noteKeywords != null) {
      map['note_keywords'] = Variable<String>(noteKeywords);
    }
    if (!nullToAbsent || linkSourceLabel != null) {
      map['link_source_label'] = Variable<String>(linkSourceLabel);
    }
    if (!nullToAbsent || linkSavedAt != null) {
      map['link_saved_at'] = Variable<int>(linkSavedAt);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    return map;
  }

  ActivityCardsCompanion toCompanion(bool nullToAbsent) {
    return ActivityCardsCompanion(
      id: Value(id),
      ownerKey: Value(ownerKey),
      title: Value(title),
      status: Value(status),
      origin: Value(origin),
      activityType: activityType == null && nullToAbsent
          ? const Value.absent()
          : Value(activityType),
      scheduledOn: scheduledOn == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledOn),
      priceVnd: priceVnd == null && nullToAbsent
          ? const Value.absent()
          : Value(priceVnd),
      distanceKm: distanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceKm),
      needsBooking: needsBooking == null && nullToAbsent
          ? const Value.absent()
          : Value(needsBooking),
      indoorOutdoor: indoorOutdoor == null && nullToAbsent
          ? const Value.absent()
          : Value(indoorOutdoor),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      sourceLink: sourceLink == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceLink),
      invited: Value(invited),
      replyState: Value(replyState),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      timeOfDaySlot: timeOfDaySlot == null && nullToAbsent
          ? const Value.absent()
          : Value(timeOfDaySlot),
      noteKeywords: noteKeywords == null && nullToAbsent
          ? const Value.absent()
          : Value(noteKeywords),
      linkSourceLabel: linkSourceLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(linkSourceLabel),
      linkSavedAt: linkSavedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(linkSavedAt),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
    );
  }

  factory ActivityCardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityCardRow(
      id: serializer.fromJson<String>(json['id']),
      ownerKey: serializer.fromJson<String>(json['ownerKey']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      origin: serializer.fromJson<String>(json['origin']),
      activityType: serializer.fromJson<ActivityType?>(json['activityType']),
      scheduledOn: serializer.fromJson<String?>(json['scheduledOn']),
      priceVnd: serializer.fromJson<int?>(json['priceVnd']),
      distanceKm: serializer.fromJson<double?>(json['distanceKm']),
      needsBooking: serializer.fromJson<bool?>(json['needsBooking']),
      indoorOutdoor: serializer.fromJson<String?>(json['indoorOutdoor']),
      note: serializer.fromJson<String?>(json['note']),
      sourceLink: serializer.fromJson<String?>(json['sourceLink']),
      invited: serializer.fromJson<bool>(json['invited']),
      replyState: serializer.fromJson<String>(json['replyState']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      timeOfDaySlot: serializer.fromJson<TimeOfDaySlot?>(json['timeOfDaySlot']),
      noteKeywords: serializer.fromJson<String?>(json['noteKeywords']),
      linkSourceLabel: serializer.fromJson<String?>(json['linkSourceLabel']),
      linkSavedAt: serializer.fromJson<int?>(json['linkSavedAt']),
      location: serializer.fromJson<String?>(json['location']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerKey': serializer.toJson<String>(ownerKey),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'origin': serializer.toJson<String>(origin),
      'activityType': serializer.toJson<ActivityType?>(activityType),
      'scheduledOn': serializer.toJson<String?>(scheduledOn),
      'priceVnd': serializer.toJson<int?>(priceVnd),
      'distanceKm': serializer.toJson<double?>(distanceKm),
      'needsBooking': serializer.toJson<bool?>(needsBooking),
      'indoorOutdoor': serializer.toJson<String?>(indoorOutdoor),
      'note': serializer.toJson<String?>(note),
      'sourceLink': serializer.toJson<String?>(sourceLink),
      'invited': serializer.toJson<bool>(invited),
      'replyState': serializer.toJson<String>(replyState),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'timeOfDaySlot': serializer.toJson<TimeOfDaySlot?>(timeOfDaySlot),
      'noteKeywords': serializer.toJson<String?>(noteKeywords),
      'linkSourceLabel': serializer.toJson<String?>(linkSourceLabel),
      'linkSavedAt': serializer.toJson<int?>(linkSavedAt),
      'location': serializer.toJson<String?>(location),
    };
  }

  ActivityCardRow copyWith({
    String? id,
    String? ownerKey,
    String? title,
    String? status,
    String? origin,
    Value<ActivityType?> activityType = const Value.absent(),
    Value<String?> scheduledOn = const Value.absent(),
    Value<int?> priceVnd = const Value.absent(),
    Value<double?> distanceKm = const Value.absent(),
    Value<bool?> needsBooking = const Value.absent(),
    Value<String?> indoorOutdoor = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> sourceLink = const Value.absent(),
    bool? invited,
    String? replyState,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<int?> durationMinutes = const Value.absent(),
    Value<TimeOfDaySlot?> timeOfDaySlot = const Value.absent(),
    Value<String?> noteKeywords = const Value.absent(),
    Value<String?> linkSourceLabel = const Value.absent(),
    Value<int?> linkSavedAt = const Value.absent(),
    Value<String?> location = const Value.absent(),
  }) => ActivityCardRow(
    id: id ?? this.id,
    ownerKey: ownerKey ?? this.ownerKey,
    title: title ?? this.title,
    status: status ?? this.status,
    origin: origin ?? this.origin,
    activityType: activityType.present ? activityType.value : this.activityType,
    scheduledOn: scheduledOn.present ? scheduledOn.value : this.scheduledOn,
    priceVnd: priceVnd.present ? priceVnd.value : this.priceVnd,
    distanceKm: distanceKm.present ? distanceKm.value : this.distanceKm,
    needsBooking: needsBooking.present ? needsBooking.value : this.needsBooking,
    indoorOutdoor: indoorOutdoor.present
        ? indoorOutdoor.value
        : this.indoorOutdoor,
    note: note.present ? note.value : this.note,
    sourceLink: sourceLink.present ? sourceLink.value : this.sourceLink,
    invited: invited ?? this.invited,
    replyState: replyState ?? this.replyState,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    durationMinutes: durationMinutes.present
        ? durationMinutes.value
        : this.durationMinutes,
    timeOfDaySlot: timeOfDaySlot.present
        ? timeOfDaySlot.value
        : this.timeOfDaySlot,
    noteKeywords: noteKeywords.present ? noteKeywords.value : this.noteKeywords,
    linkSourceLabel: linkSourceLabel.present
        ? linkSourceLabel.value
        : this.linkSourceLabel,
    linkSavedAt: linkSavedAt.present ? linkSavedAt.value : this.linkSavedAt,
    location: location.present ? location.value : this.location,
  );
  ActivityCardRow copyWithCompanion(ActivityCardsCompanion data) {
    return ActivityCardRow(
      id: data.id.present ? data.id.value : this.id,
      ownerKey: data.ownerKey.present ? data.ownerKey.value : this.ownerKey,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      origin: data.origin.present ? data.origin.value : this.origin,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      scheduledOn: data.scheduledOn.present
          ? data.scheduledOn.value
          : this.scheduledOn,
      priceVnd: data.priceVnd.present ? data.priceVnd.value : this.priceVnd,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      needsBooking: data.needsBooking.present
          ? data.needsBooking.value
          : this.needsBooking,
      indoorOutdoor: data.indoorOutdoor.present
          ? data.indoorOutdoor.value
          : this.indoorOutdoor,
      note: data.note.present ? data.note.value : this.note,
      sourceLink: data.sourceLink.present
          ? data.sourceLink.value
          : this.sourceLink,
      invited: data.invited.present ? data.invited.value : this.invited,
      replyState: data.replyState.present
          ? data.replyState.value
          : this.replyState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      timeOfDaySlot: data.timeOfDaySlot.present
          ? data.timeOfDaySlot.value
          : this.timeOfDaySlot,
      noteKeywords: data.noteKeywords.present
          ? data.noteKeywords.value
          : this.noteKeywords,
      linkSourceLabel: data.linkSourceLabel.present
          ? data.linkSourceLabel.value
          : this.linkSourceLabel,
      linkSavedAt: data.linkSavedAt.present
          ? data.linkSavedAt.value
          : this.linkSavedAt,
      location: data.location.present ? data.location.value : this.location,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityCardRow(')
          ..write('id: $id, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('activityType: $activityType, ')
          ..write('scheduledOn: $scheduledOn, ')
          ..write('priceVnd: $priceVnd, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('needsBooking: $needsBooking, ')
          ..write('indoorOutdoor: $indoorOutdoor, ')
          ..write('note: $note, ')
          ..write('sourceLink: $sourceLink, ')
          ..write('invited: $invited, ')
          ..write('replyState: $replyState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('timeOfDaySlot: $timeOfDaySlot, ')
          ..write('noteKeywords: $noteKeywords, ')
          ..write('linkSourceLabel: $linkSourceLabel, ')
          ..write('linkSavedAt: $linkSavedAt, ')
          ..write('location: $location')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ownerKey,
    title,
    status,
    origin,
    activityType,
    scheduledOn,
    priceVnd,
    distanceKm,
    needsBooking,
    indoorOutdoor,
    note,
    sourceLink,
    invited,
    replyState,
    createdAt,
    updatedAt,
    durationMinutes,
    timeOfDaySlot,
    noteKeywords,
    linkSourceLabel,
    linkSavedAt,
    location,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityCardRow &&
          other.id == this.id &&
          other.ownerKey == this.ownerKey &&
          other.title == this.title &&
          other.status == this.status &&
          other.origin == this.origin &&
          other.activityType == this.activityType &&
          other.scheduledOn == this.scheduledOn &&
          other.priceVnd == this.priceVnd &&
          other.distanceKm == this.distanceKm &&
          other.needsBooking == this.needsBooking &&
          other.indoorOutdoor == this.indoorOutdoor &&
          other.note == this.note &&
          other.sourceLink == this.sourceLink &&
          other.invited == this.invited &&
          other.replyState == this.replyState &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.durationMinutes == this.durationMinutes &&
          other.timeOfDaySlot == this.timeOfDaySlot &&
          other.noteKeywords == this.noteKeywords &&
          other.linkSourceLabel == this.linkSourceLabel &&
          other.linkSavedAt == this.linkSavedAt &&
          other.location == this.location);
}

class ActivityCardsCompanion extends UpdateCompanion<ActivityCardRow> {
  final Value<String> id;
  final Value<String> ownerKey;
  final Value<String> title;
  final Value<String> status;
  final Value<String> origin;
  final Value<ActivityType?> activityType;
  final Value<String?> scheduledOn;
  final Value<int?> priceVnd;
  final Value<double?> distanceKm;
  final Value<bool?> needsBooking;
  final Value<String?> indoorOutdoor;
  final Value<String?> note;
  final Value<String?> sourceLink;
  final Value<bool> invited;
  final Value<String> replyState;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> durationMinutes;
  final Value<TimeOfDaySlot?> timeOfDaySlot;
  final Value<String?> noteKeywords;
  final Value<String?> linkSourceLabel;
  final Value<int?> linkSavedAt;
  final Value<String?> location;
  final Value<int> rowid;
  const ActivityCardsCompanion({
    this.id = const Value.absent(),
    this.ownerKey = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.activityType = const Value.absent(),
    this.scheduledOn = const Value.absent(),
    this.priceVnd = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.needsBooking = const Value.absent(),
    this.indoorOutdoor = const Value.absent(),
    this.note = const Value.absent(),
    this.sourceLink = const Value.absent(),
    this.invited = const Value.absent(),
    this.replyState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.timeOfDaySlot = const Value.absent(),
    this.noteKeywords = const Value.absent(),
    this.linkSourceLabel = const Value.absent(),
    this.linkSavedAt = const Value.absent(),
    this.location = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityCardsCompanion.insert({
    required String id,
    required String ownerKey,
    required String title,
    this.status = const Value.absent(),
    required String origin,
    this.activityType = const Value.absent(),
    this.scheduledOn = const Value.absent(),
    this.priceVnd = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.needsBooking = const Value.absent(),
    this.indoorOutdoor = const Value.absent(),
    this.note = const Value.absent(),
    this.sourceLink = const Value.absent(),
    this.invited = const Value.absent(),
    this.replyState = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.durationMinutes = const Value.absent(),
    this.timeOfDaySlot = const Value.absent(),
    this.noteKeywords = const Value.absent(),
    this.linkSourceLabel = const Value.absent(),
    this.linkSavedAt = const Value.absent(),
    this.location = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerKey = Value(ownerKey),
       title = Value(title),
       origin = Value(origin),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ActivityCardRow> custom({
    Expression<String>? id,
    Expression<String>? ownerKey,
    Expression<String>? title,
    Expression<String>? status,
    Expression<String>? origin,
    Expression<String>? activityType,
    Expression<String>? scheduledOn,
    Expression<int>? priceVnd,
    Expression<double>? distanceKm,
    Expression<bool>? needsBooking,
    Expression<String>? indoorOutdoor,
    Expression<String>? note,
    Expression<String>? sourceLink,
    Expression<bool>? invited,
    Expression<String>? replyState,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? durationMinutes,
    Expression<String>? timeOfDaySlot,
    Expression<String>? noteKeywords,
    Expression<String>? linkSourceLabel,
    Expression<int>? linkSavedAt,
    Expression<String>? location,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerKey != null) 'owner_key': ownerKey,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (origin != null) 'origin': origin,
      if (activityType != null) 'activity_type': activityType,
      if (scheduledOn != null) 'scheduled_on': scheduledOn,
      if (priceVnd != null) 'price_vnd': priceVnd,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (needsBooking != null) 'needs_booking': needsBooking,
      if (indoorOutdoor != null) 'indoor_outdoor': indoorOutdoor,
      if (note != null) 'note': note,
      if (sourceLink != null) 'source_link': sourceLink,
      if (invited != null) 'invited': invited,
      if (replyState != null) 'reply_state': replyState,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (timeOfDaySlot != null) 'time_of_day_slot': timeOfDaySlot,
      if (noteKeywords != null) 'note_keywords': noteKeywords,
      if (linkSourceLabel != null) 'link_source_label': linkSourceLabel,
      if (linkSavedAt != null) 'link_saved_at': linkSavedAt,
      if (location != null) 'location': location,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerKey,
    Value<String>? title,
    Value<String>? status,
    Value<String>? origin,
    Value<ActivityType?>? activityType,
    Value<String?>? scheduledOn,
    Value<int?>? priceVnd,
    Value<double?>? distanceKm,
    Value<bool?>? needsBooking,
    Value<String?>? indoorOutdoor,
    Value<String?>? note,
    Value<String?>? sourceLink,
    Value<bool>? invited,
    Value<String>? replyState,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int?>? durationMinutes,
    Value<TimeOfDaySlot?>? timeOfDaySlot,
    Value<String?>? noteKeywords,
    Value<String?>? linkSourceLabel,
    Value<int?>? linkSavedAt,
    Value<String?>? location,
    Value<int>? rowid,
  }) {
    return ActivityCardsCompanion(
      id: id ?? this.id,
      ownerKey: ownerKey ?? this.ownerKey,
      title: title ?? this.title,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      activityType: activityType ?? this.activityType,
      scheduledOn: scheduledOn ?? this.scheduledOn,
      priceVnd: priceVnd ?? this.priceVnd,
      distanceKm: distanceKm ?? this.distanceKm,
      needsBooking: needsBooking ?? this.needsBooking,
      indoorOutdoor: indoorOutdoor ?? this.indoorOutdoor,
      note: note ?? this.note,
      sourceLink: sourceLink ?? this.sourceLink,
      invited: invited ?? this.invited,
      replyState: replyState ?? this.replyState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      timeOfDaySlot: timeOfDaySlot ?? this.timeOfDaySlot,
      noteKeywords: noteKeywords ?? this.noteKeywords,
      linkSourceLabel: linkSourceLabel ?? this.linkSourceLabel,
      linkSavedAt: linkSavedAt ?? this.linkSavedAt,
      location: location ?? this.location,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerKey.present) {
      map['owner_key'] = Variable<String>(ownerKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(
        $ActivityCardsTable.$converteractivityType.toSql(activityType.value),
      );
    }
    if (scheduledOn.present) {
      map['scheduled_on'] = Variable<String>(scheduledOn.value);
    }
    if (priceVnd.present) {
      map['price_vnd'] = Variable<int>(priceVnd.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (needsBooking.present) {
      map['needs_booking'] = Variable<bool>(needsBooking.value);
    }
    if (indoorOutdoor.present) {
      map['indoor_outdoor'] = Variable<String>(indoorOutdoor.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (sourceLink.present) {
      map['source_link'] = Variable<String>(sourceLink.value);
    }
    if (invited.present) {
      map['invited'] = Variable<bool>(invited.value);
    }
    if (replyState.present) {
      map['reply_state'] = Variable<String>(replyState.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (timeOfDaySlot.present) {
      map['time_of_day_slot'] = Variable<String>(
        $ActivityCardsTable.$convertertimeOfDaySlot.toSql(timeOfDaySlot.value),
      );
    }
    if (noteKeywords.present) {
      map['note_keywords'] = Variable<String>(noteKeywords.value);
    }
    if (linkSourceLabel.present) {
      map['link_source_label'] = Variable<String>(linkSourceLabel.value);
    }
    if (linkSavedAt.present) {
      map['link_saved_at'] = Variable<int>(linkSavedAt.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityCardsCompanion(')
          ..write('id: $id, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('activityType: $activityType, ')
          ..write('scheduledOn: $scheduledOn, ')
          ..write('priceVnd: $priceVnd, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('needsBooking: $needsBooking, ')
          ..write('indoorOutdoor: $indoorOutdoor, ')
          ..write('note: $note, ')
          ..write('sourceLink: $sourceLink, ')
          ..write('invited: $invited, ')
          ..write('replyState: $replyState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('timeOfDaySlot: $timeOfDaySlot, ')
          ..write('noteKeywords: $noteKeywords, ')
          ..write('linkSourceLabel: $linkSourceLabel, ')
          ..write('linkSavedAt: $linkSavedAt, ')
          ..write('location: $location, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityCardPhotosTable extends ActivityCardPhotos
    with TableInfo<$ActivityCardPhotosTable, ActivityCardPhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityCardPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activity_cards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, cardId, localPath, sortIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_card_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityCardPhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityCardPhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityCardPhotoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $ActivityCardPhotosTable createAlias(String alias) {
    return $ActivityCardPhotosTable(attachedDatabase, alias);
  }
}

class ActivityCardPhotoRow extends DataClass
    implements Insertable<ActivityCardPhotoRow> {
  final String id;
  final String cardId;
  final String localPath;
  final int sortIndex;
  const ActivityCardPhotoRow({
    required this.id,
    required this.cardId,
    required this.localPath,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['local_path'] = Variable<String>(localPath);
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  ActivityCardPhotosCompanion toCompanion(bool nullToAbsent) {
    return ActivityCardPhotosCompanion(
      id: Value(id),
      cardId: Value(cardId),
      localPath: Value(localPath),
      sortIndex: Value(sortIndex),
    );
  }

  factory ActivityCardPhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityCardPhotoRow(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'localPath': serializer.toJson<String>(localPath),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  ActivityCardPhotoRow copyWith({
    String? id,
    String? cardId,
    String? localPath,
    int? sortIndex,
  }) => ActivityCardPhotoRow(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    localPath: localPath ?? this.localPath,
    sortIndex: sortIndex ?? this.sortIndex,
  );
  ActivityCardPhotoRow copyWithCompanion(ActivityCardPhotosCompanion data) {
    return ActivityCardPhotoRow(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityCardPhotoRow(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('localPath: $localPath, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cardId, localPath, sortIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityCardPhotoRow &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.localPath == this.localPath &&
          other.sortIndex == this.sortIndex);
}

class ActivityCardPhotosCompanion
    extends UpdateCompanion<ActivityCardPhotoRow> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<String> localPath;
  final Value<int> sortIndex;
  final Value<int> rowid;
  const ActivityCardPhotosCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityCardPhotosCompanion.insert({
    required String id,
    required String cardId,
    required String localPath,
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardId = Value(cardId),
       localPath = Value(localPath);
  static Insertable<ActivityCardPhotoRow> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<String>? localPath,
    Expression<int>? sortIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (localPath != null) 'local_path': localPath,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityCardPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? cardId,
    Value<String>? localPath,
    Value<int>? sortIndex,
    Value<int>? rowid,
  }) {
    return ActivityCardPhotosCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      localPath: localPath ?? this.localPath,
      sortIndex: sortIndex ?? this.sortIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityCardPhotosCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('localPath: $localPath, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta(
    'ownerUserId',
  );
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
    'owner_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyTextMeta = const VerificationMeta(
    'bodyText',
  );
  @override
  late final GeneratedColumn<String> bodyText = GeneratedColumn<String>(
    'body_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _originRefMeta = const VerificationMeta(
    'originRef',
  );
  @override
  late final GeneratedColumn<String> originRef = GeneratedColumn<String>(
    'origin_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUserId,
    bodyText,
    createdAt,
    updatedAt,
    origin,
    originRef,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
        _ownerUserIdMeta,
        ownerUserId.isAcceptableOrUnknown(
          data['owner_user_id']!,
          _ownerUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerUserIdMeta);
    }
    if (data.containsKey('body_text')) {
      context.handle(
        _bodyTextMeta,
        bodyText.isAcceptableOrUnknown(data['body_text']!, _bodyTextMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('origin_ref')) {
      context.handle(
        _originRefMeta,
        originRef.isAcceptableOrUnknown(data['origin_ref']!, _originRefMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_user_id'],
      )!,
      bodyText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_text'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      originRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_ref'],
      ),
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  /// Client-generated UUID v4, stable for the entry's whole life: editing
  /// rewrites this row instead of creating a new one (AC-3).
  final String id;

  /// Backend `User.id`. Every read, write, and delete must filter on this
  /// column — it is the only multi-account isolation on a shared device,
  /// because [JournalDao] deliberately does not clear on sign-out.
  final String ownerUserId;

  /// May be empty when the entry carries only photos.
  final String bodyText;

  /// Epoch milliseconds UTC. Descending sort key of the entry list.
  final int createdAt;

  /// Epoch milliseconds UTC.
  final int updatedAt;

  /// `manual` | `external` — where the entry came from.
  final String origin;

  /// Opaque provenance tag set by the calling story. Never rendered, never a
  /// link.
  final String? originRef;
  const JournalEntry({
    required this.id,
    required this.ownerUserId,
    required this.bodyText,
    required this.createdAt,
    required this.updatedAt,
    required this.origin,
    this.originRef,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_user_id'] = Variable<String>(ownerUserId);
    map['body_text'] = Variable<String>(bodyText);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || originRef != null) {
      map['origin_ref'] = Variable<String>(originRef);
    }
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      ownerUserId: Value(ownerUserId),
      bodyText: Value(bodyText),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      origin: Value(origin),
      originRef: originRef == null && nullToAbsent
          ? const Value.absent()
          : Value(originRef),
    );
  }

  factory JournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<String>(json['id']),
      ownerUserId: serializer.fromJson<String>(json['ownerUserId']),
      bodyText: serializer.fromJson<String>(json['bodyText']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      origin: serializer.fromJson<String>(json['origin']),
      originRef: serializer.fromJson<String?>(json['originRef']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUserId': serializer.toJson<String>(ownerUserId),
      'bodyText': serializer.toJson<String>(bodyText),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'origin': serializer.toJson<String>(origin),
      'originRef': serializer.toJson<String?>(originRef),
    };
  }

  JournalEntry copyWith({
    String? id,
    String? ownerUserId,
    String? bodyText,
    int? createdAt,
    int? updatedAt,
    String? origin,
    Value<String?> originRef = const Value.absent(),
  }) => JournalEntry(
    id: id ?? this.id,
    ownerUserId: ownerUserId ?? this.ownerUserId,
    bodyText: bodyText ?? this.bodyText,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    origin: origin ?? this.origin,
    originRef: originRef.present ? originRef.value : this.originRef,
  );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      bodyText: data.bodyText.present ? data.bodyText.value : this.bodyText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      origin: data.origin.present ? data.origin.value : this.origin,
      originRef: data.originRef.present ? data.originRef.value : this.originRef,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('bodyText: $bodyText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('origin: $origin, ')
          ..write('originRef: $originRef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUserId,
    bodyText,
    createdAt,
    updatedAt,
    origin,
    originRef,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.ownerUserId == this.ownerUserId &&
          other.bodyText == this.bodyText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.origin == this.origin &&
          other.originRef == this.originRef);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<String> id;
  final Value<String> ownerUserId;
  final Value<String> bodyText;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> origin;
  final Value<String?> originRef;
  final Value<int> rowid;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.originRef = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    required String id,
    required String ownerUserId,
    required String bodyText,
    required int createdAt,
    required int updatedAt,
    this.origin = const Value.absent(),
    this.originRef = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerUserId = Value(ownerUserId),
       bodyText = Value(bodyText),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<JournalEntry> custom({
    Expression<String>? id,
    Expression<String>? ownerUserId,
    Expression<String>? bodyText,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? origin,
    Expression<String>? originRef,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (bodyText != null) 'body_text': bodyText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (origin != null) 'origin': origin,
      if (originRef != null) 'origin_ref': originRef,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerUserId,
    Value<String>? bodyText,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? origin,
    Value<String?>? originRef,
    Value<int>? rowid,
  }) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      bodyText: bodyText ?? this.bodyText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      origin: origin ?? this.origin,
      originRef: originRef ?? this.originRef,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (bodyText.present) {
      map['body_text'] = Variable<String>(bodyText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (originRef.present) {
      map['origin_ref'] = Variable<String>(originRef.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('bodyText: $bodyText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('origin: $origin, ')
          ..write('originRef: $originRef, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalPhotosTable extends JournalPhotos
    with TableInfo<$JournalPhotosTable, JournalPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journal_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    relativePath,
    sortIndex,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $JournalPhotosTable createAlias(String alias) {
    return $JournalPhotosTable(attachedDatabase, alias);
  }
}

class JournalPhoto extends DataClass implements Insertable<JournalPhoto> {
  final String id;
  final String entryId;

  /// Relative to the journal media root, never an absolute path — the app
  /// sandbox directory changes between installs and OS upgrades.
  final String relativePath;
  final int sortIndex;

  /// Epoch milliseconds UTC.
  final int createdAt;
  const JournalPhoto({
    required this.id,
    required this.entryId,
    required this.relativePath,
    required this.sortIndex,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_id'] = Variable<String>(entryId);
    map['relative_path'] = Variable<String>(relativePath);
    map['sort_index'] = Variable<int>(sortIndex);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  JournalPhotosCompanion toCompanion(bool nullToAbsent) {
    return JournalPhotosCompanion(
      id: Value(id),
      entryId: Value(entryId),
      relativePath: Value(relativePath),
      sortIndex: Value(sortIndex),
      createdAt: Value(createdAt),
    );
  }

  factory JournalPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalPhoto(
      id: serializer.fromJson<String>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryId': serializer.toJson<String>(entryId),
      'relativePath': serializer.toJson<String>(relativePath),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  JournalPhoto copyWith({
    String? id,
    String? entryId,
    String? relativePath,
    int? sortIndex,
    int? createdAt,
  }) => JournalPhoto(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    relativePath: relativePath ?? this.relativePath,
    sortIndex: sortIndex ?? this.sortIndex,
    createdAt: createdAt ?? this.createdAt,
  );
  JournalPhoto copyWithCompanion(JournalPhotosCompanion data) {
    return JournalPhoto(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalPhoto(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('relativePath: $relativePath, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entryId, relativePath, sortIndex, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalPhoto &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.relativePath == this.relativePath &&
          other.sortIndex == this.sortIndex &&
          other.createdAt == this.createdAt);
}

class JournalPhotosCompanion extends UpdateCompanion<JournalPhoto> {
  final Value<String> id;
  final Value<String> entryId;
  final Value<String> relativePath;
  final Value<int> sortIndex;
  final Value<int> createdAt;
  final Value<int> rowid;
  const JournalPhotosCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalPhotosCompanion.insert({
    required String id,
    required String entryId,
    required String relativePath,
    required int sortIndex,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entryId = Value(entryId),
       relativePath = Value(relativePath),
       sortIndex = Value(sortIndex),
       createdAt = Value(createdAt);
  static Insertable<JournalPhoto> custom({
    Expression<String>? id,
    Expression<String>? entryId,
    Expression<String>? relativePath,
    Expression<int>? sortIndex,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (relativePath != null) 'relative_path': relativePath,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? entryId,
    Value<String>? relativePath,
    Value<int>? sortIndex,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return JournalPhotosCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      relativePath: relativePath ?? this.relativePath,
      sortIndex: sortIndex ?? this.sortIndex,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalPhotosCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('relativePath: $relativePath, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InviteMessagesTable extends InviteMessages
    with TableInfo<$InviteMessagesTable, InviteMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InviteMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activity_cards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packVersionMeta = const VerificationMeta(
    'packVersion',
  );
  @override
  late final GeneratedColumn<String> packVersion = GeneratedColumn<String>(
    'pack_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filledValuesMeta = const VerificationMeta(
    'filledValues',
  );
  @override
  late final GeneratedColumn<String> filledValues = GeneratedColumn<String>(
    'filled_values',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userEditedTextMeta = const VerificationMeta(
    'userEditedText',
  );
  @override
  late final GeneratedColumn<String> userEditedText = GeneratedColumn<String>(
    'user_edited_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    categoryId,
    presetId,
    packVersion,
    filledValues,
    userEditedText,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invite_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<InviteMessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_presetIdMeta);
    }
    if (data.containsKey('pack_version')) {
      context.handle(
        _packVersionMeta,
        packVersion.isAcceptableOrUnknown(
          data['pack_version']!,
          _packVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packVersionMeta);
    }
    if (data.containsKey('filled_values')) {
      context.handle(
        _filledValuesMeta,
        filledValues.isAcceptableOrUnknown(
          data['filled_values']!,
          _filledValuesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_filledValuesMeta);
    }
    if (data.containsKey('user_edited_text')) {
      context.handle(
        _userEditedTextMeta,
        userEditedText.isAcceptableOrUnknown(
          data['user_edited_text']!,
          _userEditedTextMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InviteMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InviteMessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      )!,
      packVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_version'],
      )!,
      filledValues: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filled_values'],
      )!,
      userEditedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_edited_text'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InviteMessagesTable createAlias(String alias) {
    return $InviteMessagesTable(attachedDatabase, alias);
  }
}

class InviteMessageRow extends DataClass
    implements Insertable<InviteMessageRow> {
  /// Client-generated UUID v4, permanently stable.
  final String id;

  /// The card this invite was composed from. `ON DELETE CASCADE` (BR-2):
  /// deleting a card takes its invites with it, and enforcement depends on the
  /// `PRAGMA foreign_keys = ON` that `beforeOpen` sets on every connection.
  final String cardId;

  /// Preset category; `invite` is the only one this story ships (AC-22).
  final String categoryId;

  /// `items[].id` of the preset used, stable across pack versions.
  final String presetId;

  /// `version` of the content package at export time, so a later pack revision
  /// is detectable instead of silently changing an already-sent invite.
  final String packVersion;

  /// JSON object `{variableName: value}` holding only the variables that had
  /// data — the mad-libs input, not the output.
  final String filledValues;

  /// The user's manual override of the rendered text (AC-7). `NULL` means the
  /// user did not edit, not "empty invite".
  final String? userEditedText;

  /// Epoch milliseconds at the moment the user tapped share. INTEGER rather
  /// than a `DateTimeColumn`, matching the `link_saved_at` precedent.
  final int createdAt;
  const InviteMessageRow({
    required this.id,
    required this.cardId,
    required this.categoryId,
    required this.presetId,
    required this.packVersion,
    required this.filledValues,
    this.userEditedText,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['category_id'] = Variable<String>(categoryId);
    map['preset_id'] = Variable<String>(presetId);
    map['pack_version'] = Variable<String>(packVersion);
    map['filled_values'] = Variable<String>(filledValues);
    if (!nullToAbsent || userEditedText != null) {
      map['user_edited_text'] = Variable<String>(userEditedText);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  InviteMessagesCompanion toCompanion(bool nullToAbsent) {
    return InviteMessagesCompanion(
      id: Value(id),
      cardId: Value(cardId),
      categoryId: Value(categoryId),
      presetId: Value(presetId),
      packVersion: Value(packVersion),
      filledValues: Value(filledValues),
      userEditedText: userEditedText == null && nullToAbsent
          ? const Value.absent()
          : Value(userEditedText),
      createdAt: Value(createdAt),
    );
  }

  factory InviteMessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InviteMessageRow(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      presetId: serializer.fromJson<String>(json['presetId']),
      packVersion: serializer.fromJson<String>(json['packVersion']),
      filledValues: serializer.fromJson<String>(json['filledValues']),
      userEditedText: serializer.fromJson<String?>(json['userEditedText']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'categoryId': serializer.toJson<String>(categoryId),
      'presetId': serializer.toJson<String>(presetId),
      'packVersion': serializer.toJson<String>(packVersion),
      'filledValues': serializer.toJson<String>(filledValues),
      'userEditedText': serializer.toJson<String?>(userEditedText),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  InviteMessageRow copyWith({
    String? id,
    String? cardId,
    String? categoryId,
    String? presetId,
    String? packVersion,
    String? filledValues,
    Value<String?> userEditedText = const Value.absent(),
    int? createdAt,
  }) => InviteMessageRow(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    categoryId: categoryId ?? this.categoryId,
    presetId: presetId ?? this.presetId,
    packVersion: packVersion ?? this.packVersion,
    filledValues: filledValues ?? this.filledValues,
    userEditedText: userEditedText.present
        ? userEditedText.value
        : this.userEditedText,
    createdAt: createdAt ?? this.createdAt,
  );
  InviteMessageRow copyWithCompanion(InviteMessagesCompanion data) {
    return InviteMessageRow(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      packVersion: data.packVersion.present
          ? data.packVersion.value
          : this.packVersion,
      filledValues: data.filledValues.present
          ? data.filledValues.value
          : this.filledValues,
      userEditedText: data.userEditedText.present
          ? data.userEditedText.value
          : this.userEditedText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InviteMessageRow(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('categoryId: $categoryId, ')
          ..write('presetId: $presetId, ')
          ..write('packVersion: $packVersion, ')
          ..write('filledValues: $filledValues, ')
          ..write('userEditedText: $userEditedText, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    categoryId,
    presetId,
    packVersion,
    filledValues,
    userEditedText,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InviteMessageRow &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.categoryId == this.categoryId &&
          other.presetId == this.presetId &&
          other.packVersion == this.packVersion &&
          other.filledValues == this.filledValues &&
          other.userEditedText == this.userEditedText &&
          other.createdAt == this.createdAt);
}

class InviteMessagesCompanion extends UpdateCompanion<InviteMessageRow> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<String> categoryId;
  final Value<String> presetId;
  final Value<String> packVersion;
  final Value<String> filledValues;
  final Value<String?> userEditedText;
  final Value<int> createdAt;
  final Value<int> rowid;
  const InviteMessagesCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.presetId = const Value.absent(),
    this.packVersion = const Value.absent(),
    this.filledValues = const Value.absent(),
    this.userEditedText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InviteMessagesCompanion.insert({
    required String id,
    required String cardId,
    required String categoryId,
    required String presetId,
    required String packVersion,
    required String filledValues,
    this.userEditedText = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardId = Value(cardId),
       categoryId = Value(categoryId),
       presetId = Value(presetId),
       packVersion = Value(packVersion),
       filledValues = Value(filledValues),
       createdAt = Value(createdAt);
  static Insertable<InviteMessageRow> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<String>? categoryId,
    Expression<String>? presetId,
    Expression<String>? packVersion,
    Expression<String>? filledValues,
    Expression<String>? userEditedText,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (categoryId != null) 'category_id': categoryId,
      if (presetId != null) 'preset_id': presetId,
      if (packVersion != null) 'pack_version': packVersion,
      if (filledValues != null) 'filled_values': filledValues,
      if (userEditedText != null) 'user_edited_text': userEditedText,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InviteMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? cardId,
    Value<String>? categoryId,
    Value<String>? presetId,
    Value<String>? packVersion,
    Value<String>? filledValues,
    Value<String?>? userEditedText,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return InviteMessagesCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      categoryId: categoryId ?? this.categoryId,
      presetId: presetId ?? this.presetId,
      packVersion: packVersion ?? this.packVersion,
      filledValues: filledValues ?? this.filledValues,
      userEditedText: userEditedText ?? this.userEditedText,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (packVersion.present) {
      map['pack_version'] = Variable<String>(packVersion.value);
    }
    if (filledValues.present) {
      map['filled_values'] = Variable<String>(filledValues.value);
    }
    if (userEditedText.present) {
      map['user_edited_text'] = Variable<String>(userEditedText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InviteMessagesCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('categoryId: $categoryId, ')
          ..write('presetId: $presetId, ')
          ..write('packVersion: $packVersion, ')
          ..write('filledValues: $filledValues, ')
          ..write('userEditedText: $userEditedText, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotebookEntriesTable extends NotebookEntries
    with TableInfo<$NotebookEntriesTable, NotebookEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotebookEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerKeyMeta = const VerificationMeta(
    'ownerKey',
  );
  @override
  late final GeneratedColumn<String> ownerKey = GeneratedColumn<String>(
    'owner_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventOnMeta = const VerificationMeta(
    'eventOn',
  );
  @override
  late final GeneratedColumn<String> eventOn = GeneratedColumn<String>(
    'event_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerKey,
    kind,
    value,
    detail,
    eventOn,
    source,
    questionId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notebook_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotebookEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_key')) {
      context.handle(
        _ownerKeyMeta,
        ownerKey.isAcceptableOrUnknown(data['owner_key']!, _ownerKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerKeyMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    if (data.containsKey('event_on')) {
      context.handle(
        _eventOnMeta,
        eventOn.isAcceptableOrUnknown(data['event_on']!, _eventOnMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotebookEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotebookEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_key'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
      eventOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_on'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotebookEntriesTable createAlias(String alias) {
    return $NotebookEntriesTable(attachedDatabase, alias);
  }
}

class NotebookEntryRow extends DataClass
    implements Insertable<NotebookEntryRow> {
  /// Client-generated UUID v4, permanently stable (R-15a) — never a
  /// rowid/autoincrement, because later phases reference entries by this id.
  final String id;

  /// Backend `User.id`; every query filters on this column.
  final String ownerKey;

  /// `interest` | `event` — a closed enum (R-1f, §2). There is deliberately no
  /// third "nhận xét về người ấy" kind (AC-6).
  final String kind;

  /// What the user wrote, verbatim after trimming.
  final String value;

  /// A note *inside* this same entry, not a third category (AC-6).
  final String? detail;

  /// Civil date `YYYY-MM-DD`, meaningful only when [kind] is `event`.
  /// Deliberately not a DateTime so it never shifts with the host's UTC offset.
  final String? eventOn;

  /// `ask_on_the_spot` | `manual` (§2). Internal provenance, never rendered as
  /// a metric.
  final String source;

  /// Stable id of the question that produced this entry, so the answer reads
  /// back attached to its question (AC-4). NULL for a manually typed entry.
  final String? questionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NotebookEntryRow({
    required this.id,
    required this.ownerKey,
    required this.kind,
    required this.value,
    this.detail,
    this.eventOn,
    required this.source,
    this.questionId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_key'] = Variable<String>(ownerKey);
    map['kind'] = Variable<String>(kind);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    if (!nullToAbsent || eventOn != null) {
      map['event_on'] = Variable<String>(eventOn);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || questionId != null) {
      map['question_id'] = Variable<String>(questionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotebookEntriesCompanion toCompanion(bool nullToAbsent) {
    return NotebookEntriesCompanion(
      id: Value(id),
      ownerKey: Value(ownerKey),
      kind: Value(kind),
      value: Value(value),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
      eventOn: eventOn == null && nullToAbsent
          ? const Value.absent()
          : Value(eventOn),
      source: Value(source),
      questionId: questionId == null && nullToAbsent
          ? const Value.absent()
          : Value(questionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NotebookEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotebookEntryRow(
      id: serializer.fromJson<String>(json['id']),
      ownerKey: serializer.fromJson<String>(json['ownerKey']),
      kind: serializer.fromJson<String>(json['kind']),
      value: serializer.fromJson<String>(json['value']),
      detail: serializer.fromJson<String?>(json['detail']),
      eventOn: serializer.fromJson<String?>(json['eventOn']),
      source: serializer.fromJson<String>(json['source']),
      questionId: serializer.fromJson<String?>(json['questionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerKey': serializer.toJson<String>(ownerKey),
      'kind': serializer.toJson<String>(kind),
      'value': serializer.toJson<String>(value),
      'detail': serializer.toJson<String?>(detail),
      'eventOn': serializer.toJson<String?>(eventOn),
      'source': serializer.toJson<String>(source),
      'questionId': serializer.toJson<String?>(questionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NotebookEntryRow copyWith({
    String? id,
    String? ownerKey,
    String? kind,
    String? value,
    Value<String?> detail = const Value.absent(),
    Value<String?> eventOn = const Value.absent(),
    String? source,
    Value<String?> questionId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NotebookEntryRow(
    id: id ?? this.id,
    ownerKey: ownerKey ?? this.ownerKey,
    kind: kind ?? this.kind,
    value: value ?? this.value,
    detail: detail.present ? detail.value : this.detail,
    eventOn: eventOn.present ? eventOn.value : this.eventOn,
    source: source ?? this.source,
    questionId: questionId.present ? questionId.value : this.questionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NotebookEntryRow copyWithCompanion(NotebookEntriesCompanion data) {
    return NotebookEntryRow(
      id: data.id.present ? data.id.value : this.id,
      ownerKey: data.ownerKey.present ? data.ownerKey.value : this.ownerKey,
      kind: data.kind.present ? data.kind.value : this.kind,
      value: data.value.present ? data.value.value : this.value,
      detail: data.detail.present ? data.detail.value : this.detail,
      eventOn: data.eventOn.present ? data.eventOn.value : this.eventOn,
      source: data.source.present ? data.source.value : this.source,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotebookEntryRow(')
          ..write('id: $id, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('detail: $detail, ')
          ..write('eventOn: $eventOn, ')
          ..write('source: $source, ')
          ..write('questionId: $questionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerKey,
    kind,
    value,
    detail,
    eventOn,
    source,
    questionId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotebookEntryRow &&
          other.id == this.id &&
          other.ownerKey == this.ownerKey &&
          other.kind == this.kind &&
          other.value == this.value &&
          other.detail == this.detail &&
          other.eventOn == this.eventOn &&
          other.source == this.source &&
          other.questionId == this.questionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotebookEntriesCompanion extends UpdateCompanion<NotebookEntryRow> {
  final Value<String> id;
  final Value<String> ownerKey;
  final Value<String> kind;
  final Value<String> value;
  final Value<String?> detail;
  final Value<String?> eventOn;
  final Value<String> source;
  final Value<String?> questionId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NotebookEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerKey = const Value.absent(),
    this.kind = const Value.absent(),
    this.value = const Value.absent(),
    this.detail = const Value.absent(),
    this.eventOn = const Value.absent(),
    this.source = const Value.absent(),
    this.questionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotebookEntriesCompanion.insert({
    required String id,
    required String ownerKey,
    required String kind,
    required String value,
    this.detail = const Value.absent(),
    this.eventOn = const Value.absent(),
    required String source,
    this.questionId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerKey = Value(ownerKey),
       kind = Value(kind),
       value = Value(value),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NotebookEntryRow> custom({
    Expression<String>? id,
    Expression<String>? ownerKey,
    Expression<String>? kind,
    Expression<String>? value,
    Expression<String>? detail,
    Expression<String>? eventOn,
    Expression<String>? source,
    Expression<String>? questionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerKey != null) 'owner_key': ownerKey,
      if (kind != null) 'kind': kind,
      if (value != null) 'value': value,
      if (detail != null) 'detail': detail,
      if (eventOn != null) 'event_on': eventOn,
      if (source != null) 'source': source,
      if (questionId != null) 'question_id': questionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotebookEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerKey,
    Value<String>? kind,
    Value<String>? value,
    Value<String?>? detail,
    Value<String?>? eventOn,
    Value<String>? source,
    Value<String?>? questionId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return NotebookEntriesCompanion(
      id: id ?? this.id,
      ownerKey: ownerKey ?? this.ownerKey,
      kind: kind ?? this.kind,
      value: value ?? this.value,
      detail: detail ?? this.detail,
      eventOn: eventOn ?? this.eventOn,
      source: source ?? this.source,
      questionId: questionId ?? this.questionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerKey.present) {
      map['owner_key'] = Variable<String>(ownerKey.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (eventOn.present) {
      map['event_on'] = Variable<String>(eventOn.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotebookEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('detail: $detail, ')
          ..write('eventOn: $eventOn, ')
          ..write('source: $source, ')
          ..write('questionId: $questionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SkillProfileEntriesTable extends SkillProfileEntries
    with TableInfo<$SkillProfileEntriesTable, SkillProfileEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkillProfileEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerKeyMeta = const VerificationMeta(
    'ownerKey',
  );
  @override
  late final GeneratedColumn<String> ownerKey = GeneratedColumn<String>(
    'owner_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedIdMeta = const VerificationMeta('seedId');
  @override
  late final GeneratedColumn<String> seedId = GeneratedColumn<String>(
    'seed_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerKey,
    label,
    seedId,
    source,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skill_profile_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SkillProfileEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_key')) {
      context.handle(
        _ownerKeyMeta,
        ownerKey.isAcceptableOrUnknown(data['owner_key']!, _ownerKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerKeyMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('seed_id')) {
      context.handle(
        _seedIdMeta,
        seedId.isAcceptableOrUnknown(data['seed_id']!, _seedIdMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SkillProfileEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SkillProfileEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_key'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      seedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seed_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SkillProfileEntriesTable createAlias(String alias) {
    return $SkillProfileEntriesTable(attachedDatabase, alias);
  }
}

class SkillProfileEntryRow extends DataClass
    implements Insertable<SkillProfileEntryRow> {
  final String id;
  final String ownerKey;

  /// Display label as the user chose or typed it.
  final String label;

  /// Stable `items[].id` of the seed chip this came from; NULL means the user
  /// typed it themselves.
  final String? seedId;

  /// `ask_on_the_spot` | `manual` (§2).
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SkillProfileEntryRow({
    required this.id,
    required this.ownerKey,
    required this.label,
    this.seedId,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_key'] = Variable<String>(ownerKey);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || seedId != null) {
      map['seed_id'] = Variable<String>(seedId);
    }
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SkillProfileEntriesCompanion toCompanion(bool nullToAbsent) {
    return SkillProfileEntriesCompanion(
      id: Value(id),
      ownerKey: Value(ownerKey),
      label: Value(label),
      seedId: seedId == null && nullToAbsent
          ? const Value.absent()
          : Value(seedId),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SkillProfileEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SkillProfileEntryRow(
      id: serializer.fromJson<String>(json['id']),
      ownerKey: serializer.fromJson<String>(json['ownerKey']),
      label: serializer.fromJson<String>(json['label']),
      seedId: serializer.fromJson<String?>(json['seedId']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerKey': serializer.toJson<String>(ownerKey),
      'label': serializer.toJson<String>(label),
      'seedId': serializer.toJson<String?>(seedId),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SkillProfileEntryRow copyWith({
    String? id,
    String? ownerKey,
    String? label,
    Value<String?> seedId = const Value.absent(),
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SkillProfileEntryRow(
    id: id ?? this.id,
    ownerKey: ownerKey ?? this.ownerKey,
    label: label ?? this.label,
    seedId: seedId.present ? seedId.value : this.seedId,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SkillProfileEntryRow copyWithCompanion(SkillProfileEntriesCompanion data) {
    return SkillProfileEntryRow(
      id: data.id.present ? data.id.value : this.id,
      ownerKey: data.ownerKey.present ? data.ownerKey.value : this.ownerKey,
      label: data.label.present ? data.label.value : this.label,
      seedId: data.seedId.present ? data.seedId.value : this.seedId,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SkillProfileEntryRow(')
          ..write('id: $id, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('label: $label, ')
          ..write('seedId: $seedId, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ownerKey, label, seedId, source, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SkillProfileEntryRow &&
          other.id == this.id &&
          other.ownerKey == this.ownerKey &&
          other.label == this.label &&
          other.seedId == this.seedId &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SkillProfileEntriesCompanion
    extends UpdateCompanion<SkillProfileEntryRow> {
  final Value<String> id;
  final Value<String> ownerKey;
  final Value<String> label;
  final Value<String?> seedId;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SkillProfileEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerKey = const Value.absent(),
    this.label = const Value.absent(),
    this.seedId = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SkillProfileEntriesCompanion.insert({
    required String id,
    required String ownerKey,
    required String label,
    this.seedId = const Value.absent(),
    required String source,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerKey = Value(ownerKey),
       label = Value(label),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SkillProfileEntryRow> custom({
    Expression<String>? id,
    Expression<String>? ownerKey,
    Expression<String>? label,
    Expression<String>? seedId,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerKey != null) 'owner_key': ownerKey,
      if (label != null) 'label': label,
      if (seedId != null) 'seed_id': seedId,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SkillProfileEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerKey,
    Value<String>? label,
    Value<String?>? seedId,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SkillProfileEntriesCompanion(
      id: id ?? this.id,
      ownerKey: ownerKey ?? this.ownerKey,
      label: label ?? this.label,
      seedId: seedId ?? this.seedId,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerKey.present) {
      map['owner_key'] = Variable<String>(ownerKey.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (seedId.present) {
      map['seed_id'] = Variable<String>(seedId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillProfileEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerKey: $ownerKey, ')
          ..write('label: $label, ')
          ..write('seedId: $seedId, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AskPromptStateTable extends AskPromptState
    with TableInfo<$AskPromptStateTable, AskPromptStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AskPromptStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerKeyMeta = const VerificationMeta(
    'ownerKey',
  );
  @override
  late final GeneratedColumn<String> ownerKey = GeneratedColumn<String>(
    'owner_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerKey,
    questionId,
    state,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ask_prompt_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<AskPromptStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_key')) {
      context.handle(
        _ownerKeyMeta,
        ownerKey.isAcceptableOrUnknown(data['owner_key']!, _ownerKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerKeyMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerKey, questionId};
  @override
  AskPromptStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AskPromptStateRow(
      ownerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_key'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AskPromptStateTable createAlias(String alias) {
    return $AskPromptStateTable(attachedDatabase, alias);
  }
}

class AskPromptStateRow extends DataClass
    implements Insertable<AskPromptStateRow> {
  final String ownerKey;

  /// Stable question id from `req016.ask_questions.v1`.
  final String questionId;

  /// `answered` | `skipped`.
  final String state;
  final DateTime updatedAt;
  const AskPromptStateRow({
    required this.ownerKey,
    required this.questionId,
    required this.state,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_key'] = Variable<String>(ownerKey);
    map['question_id'] = Variable<String>(questionId);
    map['state'] = Variable<String>(state);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AskPromptStateCompanion toCompanion(bool nullToAbsent) {
    return AskPromptStateCompanion(
      ownerKey: Value(ownerKey),
      questionId: Value(questionId),
      state: Value(state),
      updatedAt: Value(updatedAt),
    );
  }

  factory AskPromptStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AskPromptStateRow(
      ownerKey: serializer.fromJson<String>(json['ownerKey']),
      questionId: serializer.fromJson<String>(json['questionId']),
      state: serializer.fromJson<String>(json['state']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerKey': serializer.toJson<String>(ownerKey),
      'questionId': serializer.toJson<String>(questionId),
      'state': serializer.toJson<String>(state),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AskPromptStateRow copyWith({
    String? ownerKey,
    String? questionId,
    String? state,
    DateTime? updatedAt,
  }) => AskPromptStateRow(
    ownerKey: ownerKey ?? this.ownerKey,
    questionId: questionId ?? this.questionId,
    state: state ?? this.state,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AskPromptStateRow copyWithCompanion(AskPromptStateCompanion data) {
    return AskPromptStateRow(
      ownerKey: data.ownerKey.present ? data.ownerKey.value : this.ownerKey,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      state: data.state.present ? data.state.value : this.state,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AskPromptStateRow(')
          ..write('ownerKey: $ownerKey, ')
          ..write('questionId: $questionId, ')
          ..write('state: $state, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ownerKey, questionId, state, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AskPromptStateRow &&
          other.ownerKey == this.ownerKey &&
          other.questionId == this.questionId &&
          other.state == this.state &&
          other.updatedAt == this.updatedAt);
}

class AskPromptStateCompanion extends UpdateCompanion<AskPromptStateRow> {
  final Value<String> ownerKey;
  final Value<String> questionId;
  final Value<String> state;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AskPromptStateCompanion({
    this.ownerKey = const Value.absent(),
    this.questionId = const Value.absent(),
    this.state = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AskPromptStateCompanion.insert({
    required String ownerKey,
    required String questionId,
    required String state,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : ownerKey = Value(ownerKey),
       questionId = Value(questionId),
       state = Value(state),
       updatedAt = Value(updatedAt);
  static Insertable<AskPromptStateRow> custom({
    Expression<String>? ownerKey,
    Expression<String>? questionId,
    Expression<String>? state,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerKey != null) 'owner_key': ownerKey,
      if (questionId != null) 'question_id': questionId,
      if (state != null) 'state': state,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AskPromptStateCompanion copyWith({
    Value<String>? ownerKey,
    Value<String>? questionId,
    Value<String>? state,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AskPromptStateCompanion(
      ownerKey: ownerKey ?? this.ownerKey,
      questionId: questionId ?? this.questionId,
      state: state ?? this.state,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerKey.present) {
      map['owner_key'] = Variable<String>(ownerKey.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AskPromptStateCompanion(')
          ..write('ownerKey: $ownerKey, ')
          ..write('questionId: $questionId, ')
          ..write('state: $state, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarEventStateTable extends CalendarEventState
    with TableInfo<$CalendarEventStateTable, CalendarEventStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerKeyMeta = const VerificationMeta(
    'ownerKey',
  );
  @override
  late final GeneratedColumn<String> ownerKey = GeneratedColumn<String>(
    'owner_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [ownerKey, eventId, state, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_event_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarEventStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_key')) {
      context.handle(
        _ownerKeyMeta,
        ownerKey.isAcceptableOrUnknown(data['owner_key']!, _ownerKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerKeyMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerKey, eventId};
  @override
  CalendarEventStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEventStateRow(
      ownerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_key'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CalendarEventStateTable createAlias(String alias) {
    return $CalendarEventStateTable(attachedDatabase, alias);
  }
}

class CalendarEventStateRow extends DataClass
    implements Insertable<CalendarEventStateRow> {
  final String ownerKey;
  final String eventId;

  /// `converted` | `dismissed`.
  final String state;
  final DateTime updatedAt;
  const CalendarEventStateRow({
    required this.ownerKey,
    required this.eventId,
    required this.state,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_key'] = Variable<String>(ownerKey);
    map['event_id'] = Variable<String>(eventId);
    map['state'] = Variable<String>(state);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CalendarEventStateCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventStateCompanion(
      ownerKey: Value(ownerKey),
      eventId: Value(eventId),
      state: Value(state),
      updatedAt: Value(updatedAt),
    );
  }

  factory CalendarEventStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEventStateRow(
      ownerKey: serializer.fromJson<String>(json['ownerKey']),
      eventId: serializer.fromJson<String>(json['eventId']),
      state: serializer.fromJson<String>(json['state']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerKey': serializer.toJson<String>(ownerKey),
      'eventId': serializer.toJson<String>(eventId),
      'state': serializer.toJson<String>(state),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CalendarEventStateRow copyWith({
    String? ownerKey,
    String? eventId,
    String? state,
    DateTime? updatedAt,
  }) => CalendarEventStateRow(
    ownerKey: ownerKey ?? this.ownerKey,
    eventId: eventId ?? this.eventId,
    state: state ?? this.state,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CalendarEventStateRow copyWithCompanion(CalendarEventStateCompanion data) {
    return CalendarEventStateRow(
      ownerKey: data.ownerKey.present ? data.ownerKey.value : this.ownerKey,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      state: data.state.present ? data.state.value : this.state,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventStateRow(')
          ..write('ownerKey: $ownerKey, ')
          ..write('eventId: $eventId, ')
          ..write('state: $state, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ownerKey, eventId, state, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEventStateRow &&
          other.ownerKey == this.ownerKey &&
          other.eventId == this.eventId &&
          other.state == this.state &&
          other.updatedAt == this.updatedAt);
}

class CalendarEventStateCompanion
    extends UpdateCompanion<CalendarEventStateRow> {
  final Value<String> ownerKey;
  final Value<String> eventId;
  final Value<String> state;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CalendarEventStateCompanion({
    this.ownerKey = const Value.absent(),
    this.eventId = const Value.absent(),
    this.state = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEventStateCompanion.insert({
    required String ownerKey,
    required String eventId,
    required String state,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : ownerKey = Value(ownerKey),
       eventId = Value(eventId),
       state = Value(state),
       updatedAt = Value(updatedAt);
  static Insertable<CalendarEventStateRow> custom({
    Expression<String>? ownerKey,
    Expression<String>? eventId,
    Expression<String>? state,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerKey != null) 'owner_key': ownerKey,
      if (eventId != null) 'event_id': eventId,
      if (state != null) 'state': state,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEventStateCompanion copyWith({
    Value<String>? ownerKey,
    Value<String>? eventId,
    Value<String>? state,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CalendarEventStateCompanion(
      ownerKey: ownerKey ?? this.ownerKey,
      eventId: eventId ?? this.eventId,
      state: state ?? this.state,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerKey.present) {
      map['owner_key'] = Variable<String>(ownerKey.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventStateCompanion(')
          ..write('ownerKey: $ownerKey, ')
          ..write('eventId: $eventId, ')
          ..write('state: $state, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CupidDatabase extends GeneratedDatabase {
  _$CupidDatabase(QueryExecutor e) : super(e);
  $CupidDatabaseManager get managers => $CupidDatabaseManager(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $TimelineEntriesTable timelineEntries = $TimelineEntriesTable(
    this,
  );
  late final $TimelineSyncStateTable timelineSyncState =
      $TimelineSyncStateTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $ExpenseSyncMetadataTable expenseSyncMetadata =
      $ExpenseSyncMetadataTable(this);
  late final $ActivityCardsTable activityCards = $ActivityCardsTable(this);
  late final $ActivityCardPhotosTable activityCardPhotos =
      $ActivityCardPhotosTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $JournalPhotosTable journalPhotos = $JournalPhotosTable(this);
  late final $InviteMessagesTable inviteMessages = $InviteMessagesTable(this);
  late final $NotebookEntriesTable notebookEntries = $NotebookEntriesTable(
    this,
  );
  late final $SkillProfileEntriesTable skillProfileEntries =
      $SkillProfileEntriesTable(this);
  late final $AskPromptStateTable askPromptState = $AskPromptStateTable(this);
  late final $CalendarEventStateTable calendarEventState =
      $CalendarEventStateTable(this);
  late final Index activityCardsOwnerStatus = Index(
    'activity_cards_owner_status',
    'CREATE INDEX activity_cards_owner_status ON activity_cards (owner_key, status)',
  );
  late final MessageDao messageDao = MessageDao(this as CupidDatabase);
  late final TimelineDao timelineDao = TimelineDao(this as CupidDatabase);
  late final ExpenseDao expenseDao = ExpenseDao(this as CupidDatabase);
  late final ActivityCardDao activityCardDao = ActivityCardDao(
    this as CupidDatabase,
  );
  late final JournalDao journalDao = JournalDao(this as CupidDatabase);
  late final InviteMessageDao inviteMessageDao = InviteMessageDao(
    this as CupidDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    messages,
    timelineEntries,
    timelineSyncState,
    expenses,
    expenseSyncMetadata,
    activityCards,
    activityCardPhotos,
    journalEntries,
    journalPhotos,
    inviteMessages,
    notebookEntries,
    skillProfileEntries,
    askPromptState,
    calendarEventState,
    activityCardsOwnerStatus,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activity_card_photos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'journal_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('journal_photos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activity_cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('invite_messages', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String senderId,
      required String receiverId,
      required String content,
      required String type,
      required String status,
      Value<DateTime?> readAt,
      required DateTime createdAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> senderId,
      Value<String> receiverId,
      Value<String> content,
      Value<String> type,
      Value<String> status,
      Value<DateTime?> readAt,
      Value<DateTime> createdAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$CupidDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiverId => $composableBuilder(
    column: $table.receiverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$CupidDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiverId => $composableBuilder(
    column: $table.receiverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$CupidDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get receiverId => $composableBuilder(
    column: $table.receiverId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$CupidDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$CupidDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> receiverId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                senderId: senderId,
                receiverId: receiverId,
                content: content,
                type: type,
                status: status,
                readAt: readAt,
                createdAt: createdAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String senderId,
                required String receiverId,
                required String content,
                required String type,
                required String status,
                Value<DateTime?> readAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                senderId: senderId,
                receiverId: receiverId,
                content: content,
                type: type,
                status: status,
                readAt: readAt,
                createdAt: createdAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$CupidDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $$TimelineEntriesTableCreateCompanionBuilder =
    TimelineEntriesCompanion Function({
      required String id,
      required String type,
      required String title,
      Value<String?> description,
      Value<String?> photoUrl,
      Value<String?> icon,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TimelineEntriesTableUpdateCompanionBuilder =
    TimelineEntriesCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> title,
      Value<String?> description,
      Value<String?> photoUrl,
      Value<String?> icon,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TimelineEntriesTableFilterComposer
    extends Composer<_$CupidDatabase, $TimelineEntriesTable> {
  $$TimelineEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimelineEntriesTableOrderingComposer
    extends Composer<_$CupidDatabase, $TimelineEntriesTable> {
  $$TimelineEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimelineEntriesTableAnnotationComposer
    extends Composer<_$CupidDatabase, $TimelineEntriesTable> {
  $$TimelineEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TimelineEntriesTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $TimelineEntriesTable,
          TimelineEntry,
          $$TimelineEntriesTableFilterComposer,
          $$TimelineEntriesTableOrderingComposer,
          $$TimelineEntriesTableAnnotationComposer,
          $$TimelineEntriesTableCreateCompanionBuilder,
          $$TimelineEntriesTableUpdateCompanionBuilder,
          (
            TimelineEntry,
            BaseReferences<
              _$CupidDatabase,
              $TimelineEntriesTable,
              TimelineEntry
            >,
          ),
          TimelineEntry,
          PrefetchHooks Function()
        > {
  $$TimelineEntriesTableTableManager(
    _$CupidDatabase db,
    $TimelineEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimelineEntriesCompanion(
                id: id,
                type: type,
                title: title,
                description: description,
                photoUrl: photoUrl,
                icon: icon,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TimelineEntriesCompanion.insert(
                id: id,
                type: type,
                title: title,
                description: description,
                photoUrl: photoUrl,
                icon: icon,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimelineEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $TimelineEntriesTable,
      TimelineEntry,
      $$TimelineEntriesTableFilterComposer,
      $$TimelineEntriesTableOrderingComposer,
      $$TimelineEntriesTableAnnotationComposer,
      $$TimelineEntriesTableCreateCompanionBuilder,
      $$TimelineEntriesTableUpdateCompanionBuilder,
      (
        TimelineEntry,
        BaseReferences<_$CupidDatabase, $TimelineEntriesTable, TimelineEntry>,
      ),
      TimelineEntry,
      PrefetchHooks Function()
    >;
typedef $$TimelineSyncStateTableCreateCompanionBuilder =
    TimelineSyncStateCompanion Function({
      Value<int> id,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$TimelineSyncStateTableUpdateCompanionBuilder =
    TimelineSyncStateCompanion Function({
      Value<int> id,
      Value<DateTime?> lastSyncedAt,
    });

class $$TimelineSyncStateTableFilterComposer
    extends Composer<_$CupidDatabase, $TimelineSyncStateTable> {
  $$TimelineSyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimelineSyncStateTableOrderingComposer
    extends Composer<_$CupidDatabase, $TimelineSyncStateTable> {
  $$TimelineSyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimelineSyncStateTableAnnotationComposer
    extends Composer<_$CupidDatabase, $TimelineSyncStateTable> {
  $$TimelineSyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$TimelineSyncStateTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $TimelineSyncStateTable,
          TimelineSyncStateData,
          $$TimelineSyncStateTableFilterComposer,
          $$TimelineSyncStateTableOrderingComposer,
          $$TimelineSyncStateTableAnnotationComposer,
          $$TimelineSyncStateTableCreateCompanionBuilder,
          $$TimelineSyncStateTableUpdateCompanionBuilder,
          (
            TimelineSyncStateData,
            BaseReferences<
              _$CupidDatabase,
              $TimelineSyncStateTable,
              TimelineSyncStateData
            >,
          ),
          TimelineSyncStateData,
          PrefetchHooks Function()
        > {
  $$TimelineSyncStateTableTableManager(
    _$CupidDatabase db,
    $TimelineSyncStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineSyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineSyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineSyncStateTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => TimelineSyncStateCompanion(
                id: id,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => TimelineSyncStateCompanion.insert(
                id: id,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimelineSyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $TimelineSyncStateTable,
      TimelineSyncStateData,
      $$TimelineSyncStateTableFilterComposer,
      $$TimelineSyncStateTableOrderingComposer,
      $$TimelineSyncStateTableAnnotationComposer,
      $$TimelineSyncStateTableCreateCompanionBuilder,
      $$TimelineSyncStateTableUpdateCompanionBuilder,
      (
        TimelineSyncStateData,
        BaseReferences<
          _$CupidDatabase,
          $TimelineSyncStateTable,
          TimelineSyncStateData
        >,
      ),
      TimelineSyncStateData,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String id,
      required String userId,
      required String category,
      required double amount,
      Value<String?> description,
      required DateTime date,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> category,
      Value<double> amount,
      Value<String?> description,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ExpensesTableFilterComposer
    extends Composer<_$CupidDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$CupidDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$CupidDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $ExpensesTable,
          ExpenseCacheRow,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (
            ExpenseCacheRow,
            BaseReferences<_$CupidDatabase, $ExpensesTable, ExpenseCacheRow>,
          ),
          ExpenseCacheRow,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$CupidDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                userId: userId,
                category: category,
                amount: amount,
                description: description,
                date: date,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String category,
                required double amount,
                Value<String?> description = const Value.absent(),
                required DateTime date,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                userId: userId,
                category: category,
                amount: amount,
                description: description,
                date: date,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $ExpensesTable,
      ExpenseCacheRow,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (
        ExpenseCacheRow,
        BaseReferences<_$CupidDatabase, $ExpensesTable, ExpenseCacheRow>,
      ),
      ExpenseCacheRow,
      PrefetchHooks Function()
    >;
typedef $$ExpenseSyncMetadataTableCreateCompanionBuilder =
    ExpenseSyncMetadataCompanion Function({
      Value<int> id,
      Value<DateTime?> lastSuccessfulSyncAt,
    });
typedef $$ExpenseSyncMetadataTableUpdateCompanionBuilder =
    ExpenseSyncMetadataCompanion Function({
      Value<int> id,
      Value<DateTime?> lastSuccessfulSyncAt,
    });

class $$ExpenseSyncMetadataTableFilterComposer
    extends Composer<_$CupidDatabase, $ExpenseSyncMetadataTable> {
  $$ExpenseSyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpenseSyncMetadataTableOrderingComposer
    extends Composer<_$CupidDatabase, $ExpenseSyncMetadataTable> {
  $$ExpenseSyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpenseSyncMetadataTableAnnotationComposer
    extends Composer<_$CupidDatabase, $ExpenseSyncMetadataTable> {
  $$ExpenseSyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => column,
  );
}

class $$ExpenseSyncMetadataTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $ExpenseSyncMetadataTable,
          ExpenseSyncMetadataData,
          $$ExpenseSyncMetadataTableFilterComposer,
          $$ExpenseSyncMetadataTableOrderingComposer,
          $$ExpenseSyncMetadataTableAnnotationComposer,
          $$ExpenseSyncMetadataTableCreateCompanionBuilder,
          $$ExpenseSyncMetadataTableUpdateCompanionBuilder,
          (
            ExpenseSyncMetadataData,
            BaseReferences<
              _$CupidDatabase,
              $ExpenseSyncMetadataTable,
              ExpenseSyncMetadataData
            >,
          ),
          ExpenseSyncMetadataData,
          PrefetchHooks Function()
        > {
  $$ExpenseSyncMetadataTableTableManager(
    _$CupidDatabase db,
    $ExpenseSyncMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseSyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseSyncMetadataTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExpenseSyncMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
              }) => ExpenseSyncMetadataCompanion(
                id: id,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
              }) => ExpenseSyncMetadataCompanion.insert(
                id: id,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpenseSyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $ExpenseSyncMetadataTable,
      ExpenseSyncMetadataData,
      $$ExpenseSyncMetadataTableFilterComposer,
      $$ExpenseSyncMetadataTableOrderingComposer,
      $$ExpenseSyncMetadataTableAnnotationComposer,
      $$ExpenseSyncMetadataTableCreateCompanionBuilder,
      $$ExpenseSyncMetadataTableUpdateCompanionBuilder,
      (
        ExpenseSyncMetadataData,
        BaseReferences<
          _$CupidDatabase,
          $ExpenseSyncMetadataTable,
          ExpenseSyncMetadataData
        >,
      ),
      ExpenseSyncMetadataData,
      PrefetchHooks Function()
    >;
typedef $$ActivityCardsTableCreateCompanionBuilder =
    ActivityCardsCompanion Function({
      required String id,
      required String ownerKey,
      required String title,
      Value<String> status,
      required String origin,
      Value<ActivityType?> activityType,
      Value<String?> scheduledOn,
      Value<int?> priceVnd,
      Value<double?> distanceKm,
      Value<bool?> needsBooking,
      Value<String?> indoorOutdoor,
      Value<String?> note,
      Value<String?> sourceLink,
      Value<bool> invited,
      Value<String> replyState,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int?> durationMinutes,
      Value<TimeOfDaySlot?> timeOfDaySlot,
      Value<String?> noteKeywords,
      Value<String?> linkSourceLabel,
      Value<int?> linkSavedAt,
      Value<String?> location,
      Value<int> rowid,
    });
typedef $$ActivityCardsTableUpdateCompanionBuilder =
    ActivityCardsCompanion Function({
      Value<String> id,
      Value<String> ownerKey,
      Value<String> title,
      Value<String> status,
      Value<String> origin,
      Value<ActivityType?> activityType,
      Value<String?> scheduledOn,
      Value<int?> priceVnd,
      Value<double?> distanceKm,
      Value<bool?> needsBooking,
      Value<String?> indoorOutdoor,
      Value<String?> note,
      Value<String?> sourceLink,
      Value<bool> invited,
      Value<String> replyState,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> durationMinutes,
      Value<TimeOfDaySlot?> timeOfDaySlot,
      Value<String?> noteKeywords,
      Value<String?> linkSourceLabel,
      Value<int?> linkSavedAt,
      Value<String?> location,
      Value<int> rowid,
    });

final class $$ActivityCardsTableReferences
    extends
        BaseReferences<_$CupidDatabase, $ActivityCardsTable, ActivityCardRow> {
  $$ActivityCardsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ActivityCardPhotosTable,
    List<ActivityCardPhotoRow>
  >
  _activityCardPhotosRefsTable(_$CupidDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activityCardPhotos,
        aliasName: 'activity_cards__id__activity_card_photos__card_id',
      );

  $$ActivityCardPhotosTableProcessedTableManager get activityCardPhotosRefs {
    final manager = $$ActivityCardPhotosTableTableManager(
      $_db,
      $_db.activityCardPhotos,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activityCardPhotosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InviteMessagesTable, List<InviteMessageRow>>
  _inviteMessagesRefsTable(_$CupidDatabase db) => MultiTypedResultKey.fromTable(
    db.inviteMessages,
    aliasName: 'activity_cards__id__invite_messages__card_id',
  );

  $$InviteMessagesTableProcessedTableManager get inviteMessagesRefs {
    final manager = $$InviteMessagesTableTableManager(
      $_db,
      $_db.inviteMessages,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_inviteMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActivityCardsTableFilterComposer
    extends Composer<_$CupidDatabase, $ActivityCardsTable> {
  $$ActivityCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityType?, ActivityType, String>
  get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get scheduledOn => $composableBuilder(
    column: $table.scheduledOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceVnd => $composableBuilder(
    column: $table.priceVnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsBooking => $composableBuilder(
    column: $table.needsBooking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get indoorOutdoor => $composableBuilder(
    column: $table.indoorOutdoor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLink => $composableBuilder(
    column: $table.sourceLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get invited => $composableBuilder(
    column: $table.invited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyState => $composableBuilder(
    column: $table.replyState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TimeOfDaySlot?, TimeOfDaySlot, String>
  get timeOfDaySlot => $composableBuilder(
    column: $table.timeOfDaySlot,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get noteKeywords => $composableBuilder(
    column: $table.noteKeywords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkSourceLabel => $composableBuilder(
    column: $table.linkSourceLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkSavedAt => $composableBuilder(
    column: $table.linkSavedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> activityCardPhotosRefs(
    Expression<bool> Function($$ActivityCardPhotosTableFilterComposer f) f,
  ) {
    final $$ActivityCardPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityCardPhotos,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityCardPhotosTableFilterComposer(
            $db: $db,
            $table: $db.activityCardPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inviteMessagesRefs(
    Expression<bool> Function($$InviteMessagesTableFilterComposer f) f,
  ) {
    final $$InviteMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inviteMessages,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InviteMessagesTableFilterComposer(
            $db: $db,
            $table: $db.inviteMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivityCardsTableOrderingComposer
    extends Composer<_$CupidDatabase, $ActivityCardsTable> {
  $$ActivityCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledOn => $composableBuilder(
    column: $table.scheduledOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceVnd => $composableBuilder(
    column: $table.priceVnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsBooking => $composableBuilder(
    column: $table.needsBooking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get indoorOutdoor => $composableBuilder(
    column: $table.indoorOutdoor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLink => $composableBuilder(
    column: $table.sourceLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get invited => $composableBuilder(
    column: $table.invited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyState => $composableBuilder(
    column: $table.replyState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeOfDaySlot => $composableBuilder(
    column: $table.timeOfDaySlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteKeywords => $composableBuilder(
    column: $table.noteKeywords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkSourceLabel => $composableBuilder(
    column: $table.linkSourceLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkSavedAt => $composableBuilder(
    column: $table.linkSavedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityCardsTableAnnotationComposer
    extends Composer<_$CupidDatabase, $ActivityCardsTable> {
  $$ActivityCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerKey =>
      $composableBuilder(column: $table.ownerKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityType?, String> get activityType =>
      $composableBuilder(
        column: $table.activityType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get scheduledOn => $composableBuilder(
    column: $table.scheduledOn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priceVnd =>
      $composableBuilder(column: $table.priceVnd, builder: (column) => column);

  GeneratedColumn<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsBooking => $composableBuilder(
    column: $table.needsBooking,
    builder: (column) => column,
  );

  GeneratedColumn<String> get indoorOutdoor => $composableBuilder(
    column: $table.indoorOutdoor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get sourceLink => $composableBuilder(
    column: $table.sourceLink,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get invited =>
      $composableBuilder(column: $table.invited, builder: (column) => column);

  GeneratedColumn<String> get replyState => $composableBuilder(
    column: $table.replyState,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TimeOfDaySlot?, String> get timeOfDaySlot =>
      $composableBuilder(
        column: $table.timeOfDaySlot,
        builder: (column) => column,
      );

  GeneratedColumn<String> get noteKeywords => $composableBuilder(
    column: $table.noteKeywords,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkSourceLabel => $composableBuilder(
    column: $table.linkSourceLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get linkSavedAt => $composableBuilder(
    column: $table.linkSavedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  Expression<T> activityCardPhotosRefs<T extends Object>(
    Expression<T> Function($$ActivityCardPhotosTableAnnotationComposer a) f,
  ) {
    final $$ActivityCardPhotosTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activityCardPhotos,
          getReferencedColumn: (t) => t.cardId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivityCardPhotosTableAnnotationComposer(
                $db: $db,
                $table: $db.activityCardPhotos,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> inviteMessagesRefs<T extends Object>(
    Expression<T> Function($$InviteMessagesTableAnnotationComposer a) f,
  ) {
    final $$InviteMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inviteMessages,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InviteMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.inviteMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivityCardsTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $ActivityCardsTable,
          ActivityCardRow,
          $$ActivityCardsTableFilterComposer,
          $$ActivityCardsTableOrderingComposer,
          $$ActivityCardsTableAnnotationComposer,
          $$ActivityCardsTableCreateCompanionBuilder,
          $$ActivityCardsTableUpdateCompanionBuilder,
          (ActivityCardRow, $$ActivityCardsTableReferences),
          ActivityCardRow,
          PrefetchHooks Function({
            bool activityCardPhotosRefs,
            bool inviteMessagesRefs,
          })
        > {
  $$ActivityCardsTableTableManager(
    _$CupidDatabase db,
    $ActivityCardsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<ActivityType?> activityType = const Value.absent(),
                Value<String?> scheduledOn = const Value.absent(),
                Value<int?> priceVnd = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
                Value<bool?> needsBooking = const Value.absent(),
                Value<String?> indoorOutdoor = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> sourceLink = const Value.absent(),
                Value<bool> invited = const Value.absent(),
                Value<String> replyState = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<TimeOfDaySlot?> timeOfDaySlot = const Value.absent(),
                Value<String?> noteKeywords = const Value.absent(),
                Value<String?> linkSourceLabel = const Value.absent(),
                Value<int?> linkSavedAt = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityCardsCompanion(
                id: id,
                ownerKey: ownerKey,
                title: title,
                status: status,
                origin: origin,
                activityType: activityType,
                scheduledOn: scheduledOn,
                priceVnd: priceVnd,
                distanceKm: distanceKm,
                needsBooking: needsBooking,
                indoorOutdoor: indoorOutdoor,
                note: note,
                sourceLink: sourceLink,
                invited: invited,
                replyState: replyState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                durationMinutes: durationMinutes,
                timeOfDaySlot: timeOfDaySlot,
                noteKeywords: noteKeywords,
                linkSourceLabel: linkSourceLabel,
                linkSavedAt: linkSavedAt,
                location: location,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerKey,
                required String title,
                Value<String> status = const Value.absent(),
                required String origin,
                Value<ActivityType?> activityType = const Value.absent(),
                Value<String?> scheduledOn = const Value.absent(),
                Value<int?> priceVnd = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
                Value<bool?> needsBooking = const Value.absent(),
                Value<String?> indoorOutdoor = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> sourceLink = const Value.absent(),
                Value<bool> invited = const Value.absent(),
                Value<String> replyState = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int?> durationMinutes = const Value.absent(),
                Value<TimeOfDaySlot?> timeOfDaySlot = const Value.absent(),
                Value<String?> noteKeywords = const Value.absent(),
                Value<String?> linkSourceLabel = const Value.absent(),
                Value<int?> linkSavedAt = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityCardsCompanion.insert(
                id: id,
                ownerKey: ownerKey,
                title: title,
                status: status,
                origin: origin,
                activityType: activityType,
                scheduledOn: scheduledOn,
                priceVnd: priceVnd,
                distanceKm: distanceKm,
                needsBooking: needsBooking,
                indoorOutdoor: indoorOutdoor,
                note: note,
                sourceLink: sourceLink,
                invited: invited,
                replyState: replyState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                durationMinutes: durationMinutes,
                timeOfDaySlot: timeOfDaySlot,
                noteKeywords: noteKeywords,
                linkSourceLabel: linkSourceLabel,
                linkSavedAt: linkSavedAt,
                location: location,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivityCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({activityCardPhotosRefs = false, inviteMessagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activityCardPhotosRefs) db.activityCardPhotos,
                    if (inviteMessagesRefs) db.inviteMessages,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activityCardPhotosRefs)
                        await $_getPrefetchedData<
                          ActivityCardRow,
                          $ActivityCardsTable,
                          ActivityCardPhotoRow
                        >(
                          currentTable: table,
                          referencedTable: $$ActivityCardsTableReferences
                              ._activityCardPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivityCardsTableReferences(
                                db,
                                table,
                                p0,
                              ).activityCardPhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (inviteMessagesRefs)
                        await $_getPrefetchedData<
                          ActivityCardRow,
                          $ActivityCardsTable,
                          InviteMessageRow
                        >(
                          currentTable: table,
                          referencedTable: $$ActivityCardsTableReferences
                              ._inviteMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivityCardsTableReferences(
                                db,
                                table,
                                p0,
                              ).inviteMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ActivityCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $ActivityCardsTable,
      ActivityCardRow,
      $$ActivityCardsTableFilterComposer,
      $$ActivityCardsTableOrderingComposer,
      $$ActivityCardsTableAnnotationComposer,
      $$ActivityCardsTableCreateCompanionBuilder,
      $$ActivityCardsTableUpdateCompanionBuilder,
      (ActivityCardRow, $$ActivityCardsTableReferences),
      ActivityCardRow,
      PrefetchHooks Function({
        bool activityCardPhotosRefs,
        bool inviteMessagesRefs,
      })
    >;
typedef $$ActivityCardPhotosTableCreateCompanionBuilder =
    ActivityCardPhotosCompanion Function({
      required String id,
      required String cardId,
      required String localPath,
      Value<int> sortIndex,
      Value<int> rowid,
    });
typedef $$ActivityCardPhotosTableUpdateCompanionBuilder =
    ActivityCardPhotosCompanion Function({
      Value<String> id,
      Value<String> cardId,
      Value<String> localPath,
      Value<int> sortIndex,
      Value<int> rowid,
    });

final class $$ActivityCardPhotosTableReferences
    extends
        BaseReferences<
          _$CupidDatabase,
          $ActivityCardPhotosTable,
          ActivityCardPhotoRow
        > {
  $$ActivityCardPhotosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ActivityCardsTable _cardIdTable(_$CupidDatabase db) => db
      .activityCards
      .createAlias('activity_card_photos__card_id__activity_cards__id');

  $$ActivityCardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$ActivityCardsTableTableManager(
      $_db,
      $_db.activityCards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivityCardPhotosTableFilterComposer
    extends Composer<_$CupidDatabase, $ActivityCardPhotosTable> {
  $$ActivityCardPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivityCardsTableFilterComposer get cardId {
    final $$ActivityCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.activityCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityCardsTableFilterComposer(
            $db: $db,
            $table: $db.activityCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityCardPhotosTableOrderingComposer
    extends Composer<_$CupidDatabase, $ActivityCardPhotosTable> {
  $$ActivityCardPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivityCardsTableOrderingComposer get cardId {
    final $$ActivityCardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.activityCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityCardsTableOrderingComposer(
            $db: $db,
            $table: $db.activityCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityCardPhotosTableAnnotationComposer
    extends Composer<_$CupidDatabase, $ActivityCardPhotosTable> {
  $$ActivityCardPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  $$ActivityCardsTableAnnotationComposer get cardId {
    final $$ActivityCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.activityCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.activityCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityCardPhotosTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $ActivityCardPhotosTable,
          ActivityCardPhotoRow,
          $$ActivityCardPhotosTableFilterComposer,
          $$ActivityCardPhotosTableOrderingComposer,
          $$ActivityCardPhotosTableAnnotationComposer,
          $$ActivityCardPhotosTableCreateCompanionBuilder,
          $$ActivityCardPhotosTableUpdateCompanionBuilder,
          (ActivityCardPhotoRow, $$ActivityCardPhotosTableReferences),
          ActivityCardPhotoRow,
          PrefetchHooks Function({bool cardId})
        > {
  $$ActivityCardPhotosTableTableManager(
    _$CupidDatabase db,
    $ActivityCardPhotosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityCardPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityCardPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityCardPhotosTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityCardPhotosCompanion(
                id: id,
                cardId: cardId,
                localPath: localPath,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardId,
                required String localPath,
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityCardPhotosCompanion.insert(
                id: id,
                cardId: cardId,
                localPath: localPath,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivityCardPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardId,
                                referencedTable:
                                    $$ActivityCardPhotosTableReferences
                                        ._cardIdTable(db),
                                referencedColumn:
                                    $$ActivityCardPhotosTableReferences
                                        ._cardIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActivityCardPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $ActivityCardPhotosTable,
      ActivityCardPhotoRow,
      $$ActivityCardPhotosTableFilterComposer,
      $$ActivityCardPhotosTableOrderingComposer,
      $$ActivityCardPhotosTableAnnotationComposer,
      $$ActivityCardPhotosTableCreateCompanionBuilder,
      $$ActivityCardPhotosTableUpdateCompanionBuilder,
      (ActivityCardPhotoRow, $$ActivityCardPhotosTableReferences),
      ActivityCardPhotoRow,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$JournalEntriesTableCreateCompanionBuilder =
    JournalEntriesCompanion Function({
      required String id,
      required String ownerUserId,
      required String bodyText,
      required int createdAt,
      required int updatedAt,
      Value<String> origin,
      Value<String?> originRef,
      Value<int> rowid,
    });
typedef $$JournalEntriesTableUpdateCompanionBuilder =
    JournalEntriesCompanion Function({
      Value<String> id,
      Value<String> ownerUserId,
      Value<String> bodyText,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> origin,
      Value<String?> originRef,
      Value<int> rowid,
    });

final class $$JournalEntriesTableReferences
    extends
        BaseReferences<_$CupidDatabase, $JournalEntriesTable, JournalEntry> {
  $$JournalEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$JournalPhotosTable, List<JournalPhoto>>
  _journalPhotosRefsTable(_$CupidDatabase db) => MultiTypedResultKey.fromTable(
    db.journalPhotos,
    aliasName: 'journal_entries__id__journal_photos__entry_id',
  );

  $$JournalPhotosTableProcessedTableManager get journalPhotosRefs {
    final manager = $$JournalPhotosTableTableManager(
      $_db,
      $_db.journalPhotos,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_journalPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JournalEntriesTableFilterComposer
    extends Composer<_$CupidDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyText => $composableBuilder(
    column: $table.bodyText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originRef => $composableBuilder(
    column: $table.originRef,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> journalPhotosRefs(
    Expression<bool> Function($$JournalPhotosTableFilterComposer f) f,
  ) {
    final $$JournalPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.journalPhotos,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalPhotosTableFilterComposer(
            $db: $db,
            $table: $db.journalPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$CupidDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyText => $composableBuilder(
    column: $table.bodyText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originRef => $composableBuilder(
    column: $table.originRef,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$CupidDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyText =>
      $composableBuilder(column: $table.bodyText, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get originRef =>
      $composableBuilder(column: $table.originRef, builder: (column) => column);

  Expression<T> journalPhotosRefs<T extends Object>(
    Expression<T> Function($$JournalPhotosTableAnnotationComposer a) f,
  ) {
    final $$JournalPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.journalPhotos,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.journalPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JournalEntriesTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $JournalEntriesTable,
          JournalEntry,
          $$JournalEntriesTableFilterComposer,
          $$JournalEntriesTableOrderingComposer,
          $$JournalEntriesTableAnnotationComposer,
          $$JournalEntriesTableCreateCompanionBuilder,
          $$JournalEntriesTableUpdateCompanionBuilder,
          (JournalEntry, $$JournalEntriesTableReferences),
          JournalEntry,
          PrefetchHooks Function({bool journalPhotosRefs})
        > {
  $$JournalEntriesTableTableManager(
    _$CupidDatabase db,
    $JournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerUserId = const Value.absent(),
                Value<String> bodyText = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> originRef = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion(
                id: id,
                ownerUserId: ownerUserId,
                bodyText: bodyText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                origin: origin,
                originRef: originRef,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerUserId,
                required String bodyText,
                required int createdAt,
                required int updatedAt,
                Value<String> origin = const Value.absent(),
                Value<String?> originRef = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalEntriesCompanion.insert(
                id: id,
                ownerUserId: ownerUserId,
                bodyText: bodyText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                origin: origin,
                originRef: originRef,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JournalEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({journalPhotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (journalPhotosRefs) db.journalPhotos,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (journalPhotosRefs)
                    await $_getPrefetchedData<
                      JournalEntry,
                      $JournalEntriesTable,
                      JournalPhoto
                    >(
                      currentTable: table,
                      referencedTable: $$JournalEntriesTableReferences
                          ._journalPhotosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$JournalEntriesTableReferences(
                            db,
                            table,
                            p0,
                          ).journalPhotosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.entryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$JournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $JournalEntriesTable,
      JournalEntry,
      $$JournalEntriesTableFilterComposer,
      $$JournalEntriesTableOrderingComposer,
      $$JournalEntriesTableAnnotationComposer,
      $$JournalEntriesTableCreateCompanionBuilder,
      $$JournalEntriesTableUpdateCompanionBuilder,
      (JournalEntry, $$JournalEntriesTableReferences),
      JournalEntry,
      PrefetchHooks Function({bool journalPhotosRefs})
    >;
typedef $$JournalPhotosTableCreateCompanionBuilder =
    JournalPhotosCompanion Function({
      required String id,
      required String entryId,
      required String relativePath,
      required int sortIndex,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$JournalPhotosTableUpdateCompanionBuilder =
    JournalPhotosCompanion Function({
      Value<String> id,
      Value<String> entryId,
      Value<String> relativePath,
      Value<int> sortIndex,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$JournalPhotosTableReferences
    extends BaseReferences<_$CupidDatabase, $JournalPhotosTable, JournalPhoto> {
  $$JournalPhotosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JournalEntriesTable _entryIdTable(_$CupidDatabase db) => db
      .journalEntries
      .createAlias('journal_photos__entry_id__journal_entries__id');

  $$JournalEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$JournalEntriesTableTableManager(
      $_db,
      $_db.journalEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JournalPhotosTableFilterComposer
    extends Composer<_$CupidDatabase, $JournalPhotosTable> {
  $$JournalPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$JournalEntriesTableFilterComposer get entryId {
    final $$JournalEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableFilterComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JournalPhotosTableOrderingComposer
    extends Composer<_$CupidDatabase, $JournalPhotosTable> {
  $$JournalPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$JournalEntriesTableOrderingComposer get entryId {
    final $$JournalEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JournalPhotosTableAnnotationComposer
    extends Composer<_$CupidDatabase, $JournalPhotosTable> {
  $$JournalPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$JournalEntriesTableAnnotationComposer get entryId {
    final $$JournalEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.journalEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JournalEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.journalEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JournalPhotosTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $JournalPhotosTable,
          JournalPhoto,
          $$JournalPhotosTableFilterComposer,
          $$JournalPhotosTableOrderingComposer,
          $$JournalPhotosTableAnnotationComposer,
          $$JournalPhotosTableCreateCompanionBuilder,
          $$JournalPhotosTableUpdateCompanionBuilder,
          (JournalPhoto, $$JournalPhotosTableReferences),
          JournalPhoto,
          PrefetchHooks Function({bool entryId})
        > {
  $$JournalPhotosTableTableManager(
    _$CupidDatabase db,
    $JournalPhotosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalPhotosCompanion(
                id: id,
                entryId: entryId,
                relativePath: relativePath,
                sortIndex: sortIndex,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entryId,
                required String relativePath,
                required int sortIndex,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => JournalPhotosCompanion.insert(
                id: id,
                entryId: entryId,
                relativePath: relativePath,
                sortIndex: sortIndex,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JournalPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$JournalPhotosTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$JournalPhotosTableReferences
                                    ._entryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$JournalPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $JournalPhotosTable,
      JournalPhoto,
      $$JournalPhotosTableFilterComposer,
      $$JournalPhotosTableOrderingComposer,
      $$JournalPhotosTableAnnotationComposer,
      $$JournalPhotosTableCreateCompanionBuilder,
      $$JournalPhotosTableUpdateCompanionBuilder,
      (JournalPhoto, $$JournalPhotosTableReferences),
      JournalPhoto,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$InviteMessagesTableCreateCompanionBuilder =
    InviteMessagesCompanion Function({
      required String id,
      required String cardId,
      required String categoryId,
      required String presetId,
      required String packVersion,
      required String filledValues,
      Value<String?> userEditedText,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$InviteMessagesTableUpdateCompanionBuilder =
    InviteMessagesCompanion Function({
      Value<String> id,
      Value<String> cardId,
      Value<String> categoryId,
      Value<String> presetId,
      Value<String> packVersion,
      Value<String> filledValues,
      Value<String?> userEditedText,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$InviteMessagesTableReferences
    extends
        BaseReferences<
          _$CupidDatabase,
          $InviteMessagesTable,
          InviteMessageRow
        > {
  $$InviteMessagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ActivityCardsTable _cardIdTable(_$CupidDatabase db) => db
      .activityCards
      .createAlias('invite_messages__card_id__activity_cards__id');

  $$ActivityCardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$ActivityCardsTableTableManager(
      $_db,
      $_db.activityCards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InviteMessagesTableFilterComposer
    extends Composer<_$CupidDatabase, $InviteMessagesTable> {
  $$InviteMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packVersion => $composableBuilder(
    column: $table.packVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filledValues => $composableBuilder(
    column: $table.filledValues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEditedText => $composableBuilder(
    column: $table.userEditedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivityCardsTableFilterComposer get cardId {
    final $$ActivityCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.activityCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityCardsTableFilterComposer(
            $db: $db,
            $table: $db.activityCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InviteMessagesTableOrderingComposer
    extends Composer<_$CupidDatabase, $InviteMessagesTable> {
  $$InviteMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packVersion => $composableBuilder(
    column: $table.packVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filledValues => $composableBuilder(
    column: $table.filledValues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEditedText => $composableBuilder(
    column: $table.userEditedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivityCardsTableOrderingComposer get cardId {
    final $$ActivityCardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.activityCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityCardsTableOrderingComposer(
            $db: $db,
            $table: $db.activityCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InviteMessagesTableAnnotationComposer
    extends Composer<_$CupidDatabase, $InviteMessagesTable> {
  $$InviteMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get presetId =>
      $composableBuilder(column: $table.presetId, builder: (column) => column);

  GeneratedColumn<String> get packVersion => $composableBuilder(
    column: $table.packVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filledValues => $composableBuilder(
    column: $table.filledValues,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userEditedText => $composableBuilder(
    column: $table.userEditedText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ActivityCardsTableAnnotationComposer get cardId {
    final $$ActivityCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.activityCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.activityCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InviteMessagesTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $InviteMessagesTable,
          InviteMessageRow,
          $$InviteMessagesTableFilterComposer,
          $$InviteMessagesTableOrderingComposer,
          $$InviteMessagesTableAnnotationComposer,
          $$InviteMessagesTableCreateCompanionBuilder,
          $$InviteMessagesTableUpdateCompanionBuilder,
          (InviteMessageRow, $$InviteMessagesTableReferences),
          InviteMessageRow,
          PrefetchHooks Function({bool cardId})
        > {
  $$InviteMessagesTableTableManager(
    _$CupidDatabase db,
    $InviteMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InviteMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InviteMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InviteMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> presetId = const Value.absent(),
                Value<String> packVersion = const Value.absent(),
                Value<String> filledValues = const Value.absent(),
                Value<String?> userEditedText = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InviteMessagesCompanion(
                id: id,
                cardId: cardId,
                categoryId: categoryId,
                presetId: presetId,
                packVersion: packVersion,
                filledValues: filledValues,
                userEditedText: userEditedText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardId,
                required String categoryId,
                required String presetId,
                required String packVersion,
                required String filledValues,
                Value<String?> userEditedText = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InviteMessagesCompanion.insert(
                id: id,
                cardId: cardId,
                categoryId: categoryId,
                presetId: presetId,
                packVersion: packVersion,
                filledValues: filledValues,
                userEditedText: userEditedText,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InviteMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardId,
                                referencedTable: $$InviteMessagesTableReferences
                                    ._cardIdTable(db),
                                referencedColumn:
                                    $$InviteMessagesTableReferences
                                        ._cardIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InviteMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $InviteMessagesTable,
      InviteMessageRow,
      $$InviteMessagesTableFilterComposer,
      $$InviteMessagesTableOrderingComposer,
      $$InviteMessagesTableAnnotationComposer,
      $$InviteMessagesTableCreateCompanionBuilder,
      $$InviteMessagesTableUpdateCompanionBuilder,
      (InviteMessageRow, $$InviteMessagesTableReferences),
      InviteMessageRow,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$NotebookEntriesTableCreateCompanionBuilder =
    NotebookEntriesCompanion Function({
      required String id,
      required String ownerKey,
      required String kind,
      required String value,
      Value<String?> detail,
      Value<String?> eventOn,
      required String source,
      Value<String?> questionId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$NotebookEntriesTableUpdateCompanionBuilder =
    NotebookEntriesCompanion Function({
      Value<String> id,
      Value<String> ownerKey,
      Value<String> kind,
      Value<String> value,
      Value<String?> detail,
      Value<String?> eventOn,
      Value<String> source,
      Value<String?> questionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$NotebookEntriesTableFilterComposer
    extends Composer<_$CupidDatabase, $NotebookEntriesTable> {
  $$NotebookEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventOn => $composableBuilder(
    column: $table.eventOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotebookEntriesTableOrderingComposer
    extends Composer<_$CupidDatabase, $NotebookEntriesTable> {
  $$NotebookEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventOn => $composableBuilder(
    column: $table.eventOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotebookEntriesTableAnnotationComposer
    extends Composer<_$CupidDatabase, $NotebookEntriesTable> {
  $$NotebookEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerKey =>
      $composableBuilder(column: $table.ownerKey, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get eventOn =>
      $composableBuilder(column: $table.eventOn, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotebookEntriesTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $NotebookEntriesTable,
          NotebookEntryRow,
          $$NotebookEntriesTableFilterComposer,
          $$NotebookEntriesTableOrderingComposer,
          $$NotebookEntriesTableAnnotationComposer,
          $$NotebookEntriesTableCreateCompanionBuilder,
          $$NotebookEntriesTableUpdateCompanionBuilder,
          (
            NotebookEntryRow,
            BaseReferences<
              _$CupidDatabase,
              $NotebookEntriesTable,
              NotebookEntryRow
            >,
          ),
          NotebookEntryRow,
          PrefetchHooks Function()
        > {
  $$NotebookEntriesTableTableManager(
    _$CupidDatabase db,
    $NotebookEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotebookEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotebookEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotebookEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerKey = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<String?> eventOn = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> questionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotebookEntriesCompanion(
                id: id,
                ownerKey: ownerKey,
                kind: kind,
                value: value,
                detail: detail,
                eventOn: eventOn,
                source: source,
                questionId: questionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerKey,
                required String kind,
                required String value,
                Value<String?> detail = const Value.absent(),
                Value<String?> eventOn = const Value.absent(),
                required String source,
                Value<String?> questionId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => NotebookEntriesCompanion.insert(
                id: id,
                ownerKey: ownerKey,
                kind: kind,
                value: value,
                detail: detail,
                eventOn: eventOn,
                source: source,
                questionId: questionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotebookEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $NotebookEntriesTable,
      NotebookEntryRow,
      $$NotebookEntriesTableFilterComposer,
      $$NotebookEntriesTableOrderingComposer,
      $$NotebookEntriesTableAnnotationComposer,
      $$NotebookEntriesTableCreateCompanionBuilder,
      $$NotebookEntriesTableUpdateCompanionBuilder,
      (
        NotebookEntryRow,
        BaseReferences<
          _$CupidDatabase,
          $NotebookEntriesTable,
          NotebookEntryRow
        >,
      ),
      NotebookEntryRow,
      PrefetchHooks Function()
    >;
typedef $$SkillProfileEntriesTableCreateCompanionBuilder =
    SkillProfileEntriesCompanion Function({
      required String id,
      required String ownerKey,
      required String label,
      Value<String?> seedId,
      required String source,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SkillProfileEntriesTableUpdateCompanionBuilder =
    SkillProfileEntriesCompanion Function({
      Value<String> id,
      Value<String> ownerKey,
      Value<String> label,
      Value<String?> seedId,
      Value<String> source,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SkillProfileEntriesTableFilterComposer
    extends Composer<_$CupidDatabase, $SkillProfileEntriesTable> {
  $$SkillProfileEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seedId => $composableBuilder(
    column: $table.seedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SkillProfileEntriesTableOrderingComposer
    extends Composer<_$CupidDatabase, $SkillProfileEntriesTable> {
  $$SkillProfileEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seedId => $composableBuilder(
    column: $table.seedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SkillProfileEntriesTableAnnotationComposer
    extends Composer<_$CupidDatabase, $SkillProfileEntriesTable> {
  $$SkillProfileEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerKey =>
      $composableBuilder(column: $table.ownerKey, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get seedId =>
      $composableBuilder(column: $table.seedId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SkillProfileEntriesTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $SkillProfileEntriesTable,
          SkillProfileEntryRow,
          $$SkillProfileEntriesTableFilterComposer,
          $$SkillProfileEntriesTableOrderingComposer,
          $$SkillProfileEntriesTableAnnotationComposer,
          $$SkillProfileEntriesTableCreateCompanionBuilder,
          $$SkillProfileEntriesTableUpdateCompanionBuilder,
          (
            SkillProfileEntryRow,
            BaseReferences<
              _$CupidDatabase,
              $SkillProfileEntriesTable,
              SkillProfileEntryRow
            >,
          ),
          SkillProfileEntryRow,
          PrefetchHooks Function()
        > {
  $$SkillProfileEntriesTableTableManager(
    _$CupidDatabase db,
    $SkillProfileEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkillProfileEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkillProfileEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SkillProfileEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerKey = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> seedId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SkillProfileEntriesCompanion(
                id: id,
                ownerKey: ownerKey,
                label: label,
                seedId: seedId,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerKey,
                required String label,
                Value<String?> seedId = const Value.absent(),
                required String source,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SkillProfileEntriesCompanion.insert(
                id: id,
                ownerKey: ownerKey,
                label: label,
                seedId: seedId,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SkillProfileEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $SkillProfileEntriesTable,
      SkillProfileEntryRow,
      $$SkillProfileEntriesTableFilterComposer,
      $$SkillProfileEntriesTableOrderingComposer,
      $$SkillProfileEntriesTableAnnotationComposer,
      $$SkillProfileEntriesTableCreateCompanionBuilder,
      $$SkillProfileEntriesTableUpdateCompanionBuilder,
      (
        SkillProfileEntryRow,
        BaseReferences<
          _$CupidDatabase,
          $SkillProfileEntriesTable,
          SkillProfileEntryRow
        >,
      ),
      SkillProfileEntryRow,
      PrefetchHooks Function()
    >;
typedef $$AskPromptStateTableCreateCompanionBuilder =
    AskPromptStateCompanion Function({
      required String ownerKey,
      required String questionId,
      required String state,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AskPromptStateTableUpdateCompanionBuilder =
    AskPromptStateCompanion Function({
      Value<String> ownerKey,
      Value<String> questionId,
      Value<String> state,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AskPromptStateTableFilterComposer
    extends Composer<_$CupidDatabase, $AskPromptStateTable> {
  $$AskPromptStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AskPromptStateTableOrderingComposer
    extends Composer<_$CupidDatabase, $AskPromptStateTable> {
  $$AskPromptStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AskPromptStateTableAnnotationComposer
    extends Composer<_$CupidDatabase, $AskPromptStateTable> {
  $$AskPromptStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerKey =>
      $composableBuilder(column: $table.ownerKey, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AskPromptStateTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $AskPromptStateTable,
          AskPromptStateRow,
          $$AskPromptStateTableFilterComposer,
          $$AskPromptStateTableOrderingComposer,
          $$AskPromptStateTableAnnotationComposer,
          $$AskPromptStateTableCreateCompanionBuilder,
          $$AskPromptStateTableUpdateCompanionBuilder,
          (
            AskPromptStateRow,
            BaseReferences<
              _$CupidDatabase,
              $AskPromptStateTable,
              AskPromptStateRow
            >,
          ),
          AskPromptStateRow,
          PrefetchHooks Function()
        > {
  $$AskPromptStateTableTableManager(
    _$CupidDatabase db,
    $AskPromptStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AskPromptStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AskPromptStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AskPromptStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerKey = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AskPromptStateCompanion(
                ownerKey: ownerKey,
                questionId: questionId,
                state: state,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerKey,
                required String questionId,
                required String state,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AskPromptStateCompanion.insert(
                ownerKey: ownerKey,
                questionId: questionId,
                state: state,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AskPromptStateTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $AskPromptStateTable,
      AskPromptStateRow,
      $$AskPromptStateTableFilterComposer,
      $$AskPromptStateTableOrderingComposer,
      $$AskPromptStateTableAnnotationComposer,
      $$AskPromptStateTableCreateCompanionBuilder,
      $$AskPromptStateTableUpdateCompanionBuilder,
      (
        AskPromptStateRow,
        BaseReferences<
          _$CupidDatabase,
          $AskPromptStateTable,
          AskPromptStateRow
        >,
      ),
      AskPromptStateRow,
      PrefetchHooks Function()
    >;
typedef $$CalendarEventStateTableCreateCompanionBuilder =
    CalendarEventStateCompanion Function({
      required String ownerKey,
      required String eventId,
      required String state,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CalendarEventStateTableUpdateCompanionBuilder =
    CalendarEventStateCompanion Function({
      Value<String> ownerKey,
      Value<String> eventId,
      Value<String> state,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CalendarEventStateTableFilterComposer
    extends Composer<_$CupidDatabase, $CalendarEventStateTable> {
  $$CalendarEventStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarEventStateTableOrderingComposer
    extends Composer<_$CupidDatabase, $CalendarEventStateTable> {
  $$CalendarEventStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerKey => $composableBuilder(
    column: $table.ownerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarEventStateTableAnnotationComposer
    extends Composer<_$CupidDatabase, $CalendarEventStateTable> {
  $$CalendarEventStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerKey =>
      $composableBuilder(column: $table.ownerKey, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CalendarEventStateTableTableManager
    extends
        RootTableManager<
          _$CupidDatabase,
          $CalendarEventStateTable,
          CalendarEventStateRow,
          $$CalendarEventStateTableFilterComposer,
          $$CalendarEventStateTableOrderingComposer,
          $$CalendarEventStateTableAnnotationComposer,
          $$CalendarEventStateTableCreateCompanionBuilder,
          $$CalendarEventStateTableUpdateCompanionBuilder,
          (
            CalendarEventStateRow,
            BaseReferences<
              _$CupidDatabase,
              $CalendarEventStateTable,
              CalendarEventStateRow
            >,
          ),
          CalendarEventStateRow,
          PrefetchHooks Function()
        > {
  $$CalendarEventStateTableTableManager(
    _$CupidDatabase db,
    $CalendarEventStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEventStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEventStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEventStateTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ownerKey = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventStateCompanion(
                ownerKey: ownerKey,
                eventId: eventId,
                state: state,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerKey,
                required String eventId,
                required String state,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventStateCompanion.insert(
                ownerKey: ownerKey,
                eventId: eventId,
                state: state,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarEventStateTableProcessedTableManager =
    ProcessedTableManager<
      _$CupidDatabase,
      $CalendarEventStateTable,
      CalendarEventStateRow,
      $$CalendarEventStateTableFilterComposer,
      $$CalendarEventStateTableOrderingComposer,
      $$CalendarEventStateTableAnnotationComposer,
      $$CalendarEventStateTableCreateCompanionBuilder,
      $$CalendarEventStateTableUpdateCompanionBuilder,
      (
        CalendarEventStateRow,
        BaseReferences<
          _$CupidDatabase,
          $CalendarEventStateTable,
          CalendarEventStateRow
        >,
      ),
      CalendarEventStateRow,
      PrefetchHooks Function()
    >;

class $CupidDatabaseManager {
  final _$CupidDatabase _db;
  $CupidDatabaseManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$TimelineEntriesTableTableManager get timelineEntries =>
      $$TimelineEntriesTableTableManager(_db, _db.timelineEntries);
  $$TimelineSyncStateTableTableManager get timelineSyncState =>
      $$TimelineSyncStateTableTableManager(_db, _db.timelineSyncState);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$ExpenseSyncMetadataTableTableManager get expenseSyncMetadata =>
      $$ExpenseSyncMetadataTableTableManager(_db, _db.expenseSyncMetadata);
  $$ActivityCardsTableTableManager get activityCards =>
      $$ActivityCardsTableTableManager(_db, _db.activityCards);
  $$ActivityCardPhotosTableTableManager get activityCardPhotos =>
      $$ActivityCardPhotosTableTableManager(_db, _db.activityCardPhotos);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$JournalPhotosTableTableManager get journalPhotos =>
      $$JournalPhotosTableTableManager(_db, _db.journalPhotos);
  $$InviteMessagesTableTableManager get inviteMessages =>
      $$InviteMessagesTableTableManager(_db, _db.inviteMessages);
  $$NotebookEntriesTableTableManager get notebookEntries =>
      $$NotebookEntriesTableTableManager(_db, _db.notebookEntries);
  $$SkillProfileEntriesTableTableManager get skillProfileEntries =>
      $$SkillProfileEntriesTableTableManager(_db, _db.skillProfileEntries);
  $$AskPromptStateTableTableManager get askPromptState =>
      $$AskPromptStateTableTableManager(_db, _db.askPromptState);
  $$CalendarEventStateTableTableManager get calendarEventState =>
      $$CalendarEventStateTableTableManager(_db, _db.calendarEventState);
}

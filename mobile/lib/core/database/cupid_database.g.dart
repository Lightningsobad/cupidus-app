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
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $JournalPhotosTable journalPhotos = $JournalPhotosTable(this);
  late final MessageDao messageDao = MessageDao(this as CupidDatabase);
  late final TimelineDao timelineDao = TimelineDao(this as CupidDatabase);
  late final ExpenseDao expenseDao = ExpenseDao(this as CupidDatabase);
  late final JournalDao journalDao = JournalDao(this as CupidDatabase);
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
    journalEntries,
    journalPhotos,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'journal_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('journal_photos', kind: UpdateKind.delete)],
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
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$JournalPhotosTableTableManager get journalPhotos =>
      $$JournalPhotosTableTableManager(_db, _db.journalPhotos);
}

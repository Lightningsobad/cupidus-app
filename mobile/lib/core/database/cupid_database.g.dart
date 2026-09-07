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
  static const VerificationMeta _activityTypeMeta = const VerificationMeta(
    'activityType',
  );
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
    if (data.containsKey('activity_type')) {
      context.handle(
        _activityTypeMeta,
        activityType.isAcceptableOrUnknown(
          data['activity_type']!,
          _activityTypeMeta,
        ),
      );
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
      activityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_type'],
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
    );
  }

  @override
  $ActivityCardsTable createAlias(String alias) {
    return $ActivityCardsTable(attachedDatabase, alias);
  }
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
  final String? activityType;

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
      map['activity_type'] = Variable<String>(activityType);
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
      activityType: serializer.fromJson<String?>(json['activityType']),
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
      'activityType': serializer.toJson<String?>(activityType),
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
    };
  }

  ActivityCardRow copyWith({
    String? id,
    String? ownerKey,
    String? title,
    String? status,
    String? origin,
    Value<String?> activityType = const Value.absent(),
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
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
  );
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
          other.updatedAt == this.updatedAt);
}

class ActivityCardsCompanion extends UpdateCompanion<ActivityCardRow> {
  final Value<String> id;
  final Value<String> ownerKey;
  final Value<String> title;
  final Value<String> status;
  final Value<String> origin;
  final Value<String?> activityType;
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
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerKey,
    Value<String>? title,
    Value<String>? status,
    Value<String>? origin,
    Value<String?>? activityType,
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
      map['activity_type'] = Variable<String>(activityType.value);
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
      Value<String?> activityType,
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
      Value<int> rowid,
    });
typedef $$ActivityCardsTableUpdateCompanionBuilder =
    ActivityCardsCompanion Function({
      Value<String> id,
      Value<String> ownerKey,
      Value<String> title,
      Value<String> status,
      Value<String> origin,
      Value<String?> activityType,
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

  ColumnFilters<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnFilters(column),
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

  GeneratedColumn<String> get activityType => $composableBuilder(
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
          PrefetchHooks Function({bool activityCardPhotosRefs})
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
                Value<String?> activityType = const Value.absent(),
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
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerKey,
                required String title,
                Value<String> status = const Value.absent(),
                required String origin,
                Value<String?> activityType = const Value.absent(),
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
          prefetchHooksCallback: ({activityCardPhotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (activityCardPhotosRefs) db.activityCardPhotos,
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
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.cardId == item.id),
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
      PrefetchHooks Function({bool activityCardPhotosRefs})
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
}

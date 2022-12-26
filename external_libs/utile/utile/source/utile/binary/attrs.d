module utile.binary.attrs;

class SerializerAttr
{
}

class Ignored : SerializerAttr
{
}

class ToTheEnd : SerializerAttr
{
}

class ZeroTerminated : SerializerAttr
{
}

class Skip(alias F) : SerializerAttr
{
}

class Default(alias F) : SerializerAttr
{
}

class IgnoreIf(alias F) : SerializerAttr
{
}

class Validate(alias F) : SerializerAttr
{
}

class ArrayLength(alias T) : SerializerAttr
{
}

import re
def validate_replication_tags(replication_tags):
    """
    Returns validated replication tags or raises an error.
    - 'replication_tags' should be a list of 'tag's.
    - a 'tag' should be dictionary with Keys 'Key' and 'Value'
    - the 'Key' Values should be a string with length between 0 and 127
    - the 'Value' Values should be a string with length between 0 and 255
    - the 'Key' Values should be unique
    - the 'Key' and 'Value' Values must not start with 'aws'
    - the 'Key' and 'Value' should be alphanumeric plus the \
      following special characters: + - = . _ : / @. with spaces
    """

    # helper method to validate Keys and Values
    def validate_string(val, s_type, s_max_length):
        if type(val) != str:
            raise ValueError("Non string " + s_type + " found:" + str(val))
        str_val = val.strip()
        if not len(str_val):
            raise ValueError("Empty " + s_type + " found.")
        if len(str_val) > s_max_length:
            raise ValueError("Too long " + s_type + " found: " + str_val)
        if str_val.lower().startswith("aws"):
            raise ValueError(s_type + " starting with aws found: " + str_val)
        return str_val

    # helper method to validate spedical characters in Keys or Values
    def validate_special_characters(item):
        if not re.match("^[a-zA-Z0-9\s\+\-\=\.\_\:\/\@\.]*$", item):
            raise ValueError("tag encountered with special character: " + item)

    if type(replication_tags) != list:
        raise ValueError("replication_tags should be a list")

    reserved_tags = ["Name", "Application", "JazzInstance", "Environment", "Exempt", "Owner"]
    unique_tags = []
    new_replication_tags = []
    tag_for_resource = '{'
    for tag in replication_tags:

        if not (type(tag) == dict and len(tag) == 2 and
                'Key' in tag and 'Value' in tag):
            raise ValueError("tags should be dicts with Keys 'Key' and 'Value'")

        Key = validate_string(tag['Key'], 'Key', 128)
        Value = validate_string(tag['Value'], 'Value', 256)

        validate_special_characters(Key)
        validate_special_characters(Value)

        if Key in reserved_tags:
            raise ValueError("tag encountered with reserved Key: " + Key)

        if Key in unique_tags:
            raise ValueError("tag encountered with duplicate Key: " + Key)

        unique_tags.append(Key)
        new_replication_tags.append({"Key": Key, "Value": Value})
        tag_for_resource += Key+'="'+Value + '", '
        if len(new_replication_tags) > 49:
            raise ValueError("More than 50 tags in replication settings.")
    tag_for_resource += '}'
    return new_replication_tags, tag_for_resource


def prepare_tags(input_tags_param):
    input_tags = []
    input_tags_rel = input_tags_param.split()
    for item in input_tags_rel:
      input_tags.append(dict(item2.split("=", 1) for item2 in item.split(",")))
    return input_tags

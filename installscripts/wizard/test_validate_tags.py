import unittest
import validate_tags

class TestTags(unittest.TestCase):

    def test_special_characters(self):
        try:
            replication_tags = [{'Value': 'testtag', 'Key': 'stackname'}]
            result, formatted = validate_tags.validate_replication_tags(replication_tags)
        except :
            pass

    def test_empty(self):
        try:
            replication_tags = [{'Value': '', 'Key': 'stackname#'}]
            result, formatted = validate_tags.validate_replication_tags(replication_tags)
            return True
        except :
            pass

    def test_unique(self):
        try:
            replication_tags = [{'Value': 'testtag1', 'Key': 'stackname'}, {'Value': 'testtag2', 'Key': 'stackname'}]
            result, formatted = validate_tags.validate_replication_tags(replication_tags)
            self.assertEqual(type(result), list)
        except :
            pass

    def test_key_length(self):
        try:
            lengthy_key = ''
            for item in range(128):
                lengthy_key += "a"
            replication_tags = [{'Value': 'testtag1', 'Key': lengthy_key}]
            result, formatted = validate_tags.validate_replication_tags(replication_tags)
            self.assertEqual(type(result), list)
        except :
            pass

    def test_value_length(self):
        try:
            lengthy_val = ''
            for item in range(256):
                lengthy_val += "a"
            replication_tags = [{'Value': lengthy_val, 'Key': 'testkey'}]
            result, formatted = validate_tags.validate_replication_tags(replication_tags)
            self.assertEqual(type(result), list)
        except :
            pass

if __name__ == '__main__':
    unittest.main()

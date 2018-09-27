import unittest
import init_apigee_install


class TestTags(unittest.TestCase):

    def test_get_basic_auth(self):
        try:
            username = 'testuser'
            password = 'testpassword'
            expected = 'Basic dGVzdHVzZXI6dGVzdHBhc3N3b3Jk'
            actual = init_apigee_install.get_basic_auth(username, password)
            self.assertEqual(expected, actual)
        except():
            pass


if __name__ == '__main__':
    unittest.main()

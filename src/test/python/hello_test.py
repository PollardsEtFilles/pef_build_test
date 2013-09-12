
import unittest
import hello

class hello_test(unittest.TestCase):

  def test_Hello(self):
    self.assertEqual('Hello World', hello.hello(), 'The world is quiet')

#   def test_HelloFailed(self):
#     hello = amodule.hello()
#     self.assertEqual('Hi World', hello, 'The world is quiet')


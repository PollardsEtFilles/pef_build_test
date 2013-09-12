
import unittest
import helloagain

class helloagain_test(unittest.TestCase):

  def test_helloagain(self):
    self.assertEqual('Hello World', helloagain.hello(), 'The world is quiet')

#   def test_HelloFailed(self):
#     hello = amodule.hello()
#     self.assertEqual('Hi World', hello, 'The world is quiet')


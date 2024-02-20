
# Using the Observer pattern to get the info of task execution
import logging 

logging.basicConfig(level=logging.INFO, format="%(message)s")

class Subject(object):

    def __init__(self):
        self._observers = []

    def attach(self, observer):
        if observer not in self._observers:
            self._observers.append(observer)

    def detach(self, observer):
        try:
            self._observers.remove(observer)
        except ValueError:
            pass

    def notify(self, modifier=None):
        for observer in self._observers:
            if modifier != observer:
                observer.update(self)


class Info(Subject):

    def __init__(self, name=''):
        Subject.__init__(self)
        self.name = name
        self._info = None

    @property
    def info(self):
        return self._info

    @info.setter
    def info(self, value):
        self._info = value
        self.notify()


class InfoViewer:
    def update(self, subject):
        logging.info(u'%s' % (subject.info))

try:
    set
except NameError:
    from sets import Set as set
import os, os.path
from datetime import datetime
import hype as he
import py

TESTDATA = py.magic.autopath().dirpath() / 'testdata'

formattime = lambda s: datetime.fromtimestamp(s).isoformat()
uris = lambda result: [doc['@uri'] for doc in result]

def setup_module(mod):
    mod.db = he.Database(str(py.test.ensuretemp('test_search.db')))
    mod.db.add_attr_index('@title', he.ESTIDXATTRSTR)
    for path in TESTDATA.listdir():
        if path.basename.startswith('rfc'):
            doc = he.Document(unicode(path.basename))
            stat = path.lstat()
            doc['@cdate'] = unicode(formattime(stat.ctime))
            doc['@mdate'] = unicode(formattime(stat.mtime))
            doc['@size'] = unicode(stat.size)
            doc['@title'] = unicode(path.basename)
            doc.add_text(unicode(path.read(), 'utf-8'))
            mod.db.put_doc(doc)
    db.flush()
    db.sync()
    db.optimize()

def test_phrase():
    result = db.search(u'access control')
    assert len(result) == 6
    assert uris(result) == [u'rfc1503.txt', u'rfc1507.txt', u'rfc1508.txt', u'rfc1505.txt', u'rfc1510.txt', u'rfc1538.txt']

def test_index():
    result = db.search(u'access control')
    assert result[0]['@uri'] == u'rfc1503.txt'
    py.test.raises(IndexError, result.__getitem__, 100)

def test_slice():
    result = db.search(u'access control')
    # Check a simple slice
    assert uris(result[:2]) == [u'rfc1503.txt', u'rfc1507.txt']
    # Check a new slice gives the same result
    assert uris(result[:2]) == [u'rfc1503.txt', u'rfc1507.txt']
    assert uris(result[1:2]) == [u'rfc1507.txt']
    assert uris(result[0:0]) == []
    assert uris(result[100:]) == []
    assert uris(result[100:100]) == []
    assert uris(result[:]) == [u'rfc1503.txt', u'rfc1507.txt', u'rfc1508.txt', u'rfc1505.txt', u'rfc1510.txt', u'rfc1538.txt']
    assert uris(result[:-2]) == [u'rfc1503.txt', u'rfc1507.txt', u'rfc1508.txt', u'rfc1505.txt']
    assert uris(result[::-1]) == [u'rfc1538.txt', u'rfc1510.txt',  u'rfc1505.txt',  u'rfc1508.txt',  u'rfc1507.txt',  u'rfc1503.txt']
    assert uris(result[::-1]) == [u'rfc1538.txt', u'rfc1510.txt',  u'rfc1505.txt',  u'rfc1508.txt',  u'rfc1507.txt',  u'rfc1503.txt']

def test_badslice():
    result = db.search(u'access control')
    assert uris(result[:-20]) == []
    assert uris(result[20:0]) == []
    assert uris(result[0:20:-1]) == []
    assert uris(result[20:0:1]) == []

def test_expr():
    result =  db.search(u'access control').add(u'@title STREQ rfc1503.txt')
    assert len(result) == 1
    assert uris(result) == [u'rfc1503.txt']

def test_expr2():
    result = db.search().add(u'@title STRBW rfc152')
    assert len(result) == 10
    # The order appears to be unstable, presumably because there is no search
    # phrase to score against, so compare sets
    assert set(uris(result)) == set([u'rfc1520.txt', u'rfc1521.txt', u'rfc1522.txt', u'rfc1523.txt', u'rfc1524.txt', u'rfc1525.txt', u'rfc1526.txt', u'rfc1527.txt', u'rfc1528.txt', u'rfc1529.txt'])

def test_max():
    result =  db.search(u'access control').max(2)
    assert len(result) == 2
    assert uris(result) == [u'rfc1503.txt', u'rfc1507.txt']

def test_order():
    result =  db.search(u'access control').order(u'@title STRA')
    assert len(result) == 6
    assert uris(result) == [u'rfc1503.txt', u'rfc1505.txt', u'rfc1507.txt', u'rfc1508.txt', u'rfc1510.txt', u'rfc1538.txt']

def test_offset():
    result = db.search(u'access control').order(u'@title STRA').offset(3)
    assert len(result) == 3
    assert uris(result) == [u'rfc1508.txt', u'rfc1510.txt', u'rfc1538.txt']

def test_eclipse_shadow():
    result = db.search(u'access control').order(u'@title STRA')
    result1 = db.search(u'access control').order(u'@title STRA').eclipse(0.1)
    assert len(result)
    assert len(result1)
    assert len(result1) != len(result)
    shadowed = False
    for doc in result1:
        if result1.shadows(doc):
            shadowed = True
    assert shadowed

def uri_with_scores(result):
    uris = []
    for doc, score in result:
        uris.append((doc.uri, score))
    return uris

def test_scores():
    result = db.search(u'access control').order(u'@title STRA').scores().option(he.ESTCONDSCFB)
    assert len(result)
    assert uri_with_scores(result) == [(u'rfc1503.txt', 875), (u'rfc1505.txt', 207), (u'rfc1507.txt', 426), (u'rfc1508.txt', 260), (u'rfc1510.txt', 141), (u'rfc1538.txt', 110)]

def teardown_module(mod):
    mod.db.close()


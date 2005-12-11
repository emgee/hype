import time
import rfc822
from dateutil.parser import parse

cdef extern from 'stdlib.h':
    void free(void *)

cdef extern from 'cabin.h':

    # This is a qdbm header
    ctypedef struct CBLIST:
        pass

    void cblistclose(CBLIST *list)                          # close cblist
    int cblistnum(CBLIST *list)                             # length of cblist
    char *cblistval(CBLIST *list, int index, int *sp)       # get value
    void cblistsort(CBLIST *list)                           # obvious

ESTDBREADER = 1 << 0
ESTDBWRITER = 1 << 1
ESTDBCREAT = 1 << 2
ESTDBTRUNC = 1 << 3
ESTDBNOLCK = 1 << 4
ESTDBLCKNB = 1 << 5
ESTDBPERFNG = 1 << 6

ESTCONDSURE = 1 << 0      # check every N-gram key
ESTCONDUSUAL = 1 << 1     # check N-gram keys skipping by one
ESTCONDFAST = 1 << 2      # check N-gram keys skipping by two
ESTCONDAGITO = 1 << 3     # check N-gram keys skipping by three
ESTCONDNOIDF = 1 << 4     # without TF-IDF tuning
ESTCONDSIMPLE = 1 << 10   # with the simplified phrase
ESTCONDSCFB = 1 << 30     # feed back scores (for debug)

ESTPDCLEAN = 1 << 0

ESTGDNOATTR = 1 << 0      # no attributes
ESTGDNOTEXT = 1 << 1      # no text

ESTOPTNOPURGE = 1 << 0    # omit purging dispensable region of deleted
ESTOPTNODBOPT = 1 << 1    # omit optimization of the database files

ESTODCLEAN = 1 << 0       # clean up dispensable regions

cdef extern from 'estraier.h':

    ctypedef struct ESTDB:
        pass

    ctypedef struct ESTDOC:
        pass

    ctypedef struct ESTCOND:
        pass

    ctypedef struct CBMAP:
        pass

    char *est_err_msg(int ecode)

    # Database API
    ESTDB *est_db_open(char *name, int omode, int *ecp)
    int est_db_close(ESTDB *db, int *ecp)
    int est_db_put_doc(ESTDB *db, ESTDOC *doc, int options)
    int *est_db_search(ESTDB *db, ESTCOND *cond, int *nump, CBMAP *hints)
    ESTDOC *est_db_get_doc(ESTDB *db, int id, int options)
    char *est_db_name(ESTDB *db)
    int est_db_doc_num(ESTDB *db)
    double est_db_size(ESTDB *db)
    int est_db_flush(ESTDB *db, int max)
    int est_db_sync(ESTDB *db)
    int est_db_optimize(ESTDB *db, int options)
    int est_db_uri_to_id(ESTDB *db, char *uri)
    # These are part of the Database API but they really should stay in the
    # Document like: Document.remove() and the other one used under the
    # hood when changing a document.
    int est_db_out_doc(ESTDB *db, int id, int options)
    int est_db_edit_doc(ESTDB *db, ESTDOC *doc)
    int est_db_error(ESTDB *db)
    int est_db_fatal(ESTDB *db)
    int est_db_cache_num(ESTDB *db)
    int est_db_used_cache_size(ESTDB *db)
    void est_db_set_special_cache(ESTDB *db, char *name, int num)
    void est_db_set_cache_size(ESTDB *db, int size, int anum, int tnum, int rnum)

    # Document API
    ESTDOC *est_doc_new()
    void est_doc_delete(ESTDOC *doc)
    void est_doc_add_attr(ESTDOC *doc, char *name, char *value)
    void est_doc_add_text(ESTDOC *doc, char *text)
    char *est_doc_attr(ESTDOC *doc, char *name)
    void est_doc_add_hidden_text(ESTDOC *doc, char *text)
    int est_doc_id(ESTDOC *doc)
    void est_doc_set_id(ESTDOC *doc, int id)
    ESTDOC *est_doc_new_from_draft(char *draft)
    CBLIST *est_doc_attr_names(ESTDOC *doc)
    CBLIST *est_doc_texts(ESTDOC *doc) # list of the texts added to the document
    #char *est_doc_cat_texts(ESTDOC *doc) # this is implemented in python
    char *est_doc_hidden_texts(ESTDOC *doc)

    ## Document API that still needs wrapping before the end.
    char *est_doc_dump_draft(ESTDOC *doc) # is this worth?
    # Creates the snippet with highlighted mathing *words in the *doc
    char *est_doc_make_snippet(ESTDOC *doc, CBLIST *words, int wwidth, int hwidth, int awidth)

    # Condition API
    ESTCOND *est_cond_new()
    void est_cond_delete(ESTCOND *cond)
    void est_cond_set_phrase(ESTCOND *cond, char *phrase)
    void est_cond_add_attr(ESTCOND *cond, char *expr)
    void est_cond_set_order(ESTCOND *cond, char *expr)
    void est_cond_set_max(ESTCOND *cond, int max)
    void est_cond_set_options(ESTCOND *cond, int options)
    int est_cond_score(ESTCOND *cond, int index)

class HyperEstraierError(Exception):
    pass

class DBError(HyperEstraierError):
    pass

class DocumentError(HyperEstraierError):
    pass

class DocModifyImmutableError(DocumentError):
    pass

class DocNeverAddedError(DocumentError):
    pass

class DBEditError(DBError):
    pass

class DBRemoveError(DBError):
    pass

class DBFlushError(DBError):
    pass

class DBSyncError(DBError):
    pass

class DBOptimizeError(DBError):
    pass

cdef class Database # Forward

def dt_to_str(dt, iso=True):
    if iso:
        # "%Y-%m-%dT%H:%M:%SZ%z"
        return dt.isoformat()
    # RFC2822 
    # strftime uses the locale and translates the names which is bad.
    # print dt.strftime('%a, %d %b %Y %H:%M:%S %z').strip()
    return "%s, %02d %s %04d %02d:%02d:%02d" % (
            ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][dt.isoweekday()-1],
            dt.day,
            ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][dt.month-1],
             dt.year, dt.hour, dt.minute, dt.second)

def dt_from_str(date):
    return parse(date)

def _pass(obj):
    return obj

IN, OUT = range(2)
_filters = {'@mdate': (dt_to_str, dt_from_str),
            '@adate': (dt_to_str, dt_from_str),
            '@cdate': (dt_to_str, dt_from_str),
            '@size': (str, int),
            '@weight': (str, float),
            }

cdef class Document:
    cdef ESTDOC *estdoc
    
    def __dealloc__(self):
        if self.estdoc != NULL:
            est_doc_delete(self.estdoc)
            self.estdoc = NULL

    cdef init_estdoc(self):
        """
        Internal function to ensure estdoc is allocated.
        """
        if self.estdoc == NULL:
            self.estdoc = est_doc_new()

    property id:
        " Document ID "
        def __get__(self):
            self.init_estdoc()
            return est_doc_id(self.estdoc)
        
        def __set__(self, int id):
            self.init_estdoc()
            est_doc_set_id(self.estdoc, id)

    property uri:
        def __get__(self):
            return self.get('@uri')

    property attributes:
        " A list of attribute names "
        def __get__(self):
            cdef CBLIST *attrs_c
            cdef int attrs_length, i, sp
            self.init_estdoc()
            attrs_c = est_doc_attr_names(self.estdoc)
            attrs_length = cblistnum(attrs_c)
            cblistsort(attrs_c)
            attrs = []
            for i from 0 <= i < attrs_length:
                attrs.append(cblistval(attrs_c, i, &sp))
            cblistclose(attrs_c)
            return attrs
    
    property texts:
        " A list of texts in the document "
        def __get__(self):
            cdef CBLIST *_texts
            cdef int texts_length, i, sp
            self.init_estdoc()
            _texts = est_doc_texts(self.estdoc)
            texts_length = cblistnum(_texts)
            texts = []
            for i from 0 <= i < texts_length:
                texts.append(cblistval(_texts, i, &sp))
            # We don't need to close the list since its life is already
            # synchronous with the life of the document
            return texts

    property text:
        " A concatenated list of the texts in the document "
        def __get__(self):
            return ' '.join(self.texts)
            
    property hidden_text:
        " A concatenated string of hidden text "
        def __get__(self):
            # See above, we don't need to worry about lifetime here too
            return est_doc_hidden_texts(self.estdoc)

    def __getitem__(self, name):
        value = self.get(name)
        if value is not None:
            return value
        raise KeyError('Document has no attribute %r'%name)

    def __setitem__(self, name, value):
        self.init_estdoc()
        if name == "@uri" and self.get('@uri', None):
            raise DocModifyImmutableError("Cannot modify @uri attribute")
        if not isinstance(value, basestring):
            value = _filters.get(name, (str, _pass))[IN](value)
        est_doc_add_attr(self.estdoc, name, value)

    def get(self, name, default=None):
        cdef char *value
        self.init_estdoc()
        value = est_doc_attr(self.estdoc, name)
        if value == NULL:
            return default
        return _filters.get(name, (_pass, _pass))[OUT](value)

    def add_text(self, text):
        self.init_estdoc()
        est_doc_add_text(self.estdoc, text)

    def add_hidden_text(self, text):
        self.init_estdoc()
        est_doc_add_hidden_text(self.estdoc, text)

def doc_from_string(char *data):
    cdef ESTDOC *doc_p
    cdef Document doc
    doc_p = est_doc_new_from_draft(data)
    doc = Document()
    doc.estdoc = doc_p
    return doc

cdef class Condition:
    cdef ESTCOND *estcond

    def __new__(self):
        self.estcond = est_cond_new()

    def set_phrase(self, phrase):
        est_cond_set_phrase(self.estcond, phrase)

    def add_attr(self, attr):
        est_cond_add_attr(self.estcond, attr)

    def set_order(self, order):
        est_cond_set_order(self.estcond, order)

    def set_max(self, int max):
        est_cond_set_max(self.estcond, max)

    def set_options(self, int options):
        est_cond_set_options(self.estcond, options)

    def __dealloc__(self):
        est_cond_delete(self.estcond)

cdef class Database:
    cdef ESTDB *estdb
    cdef int _ecode

    def __new__(self, name, omode=ESTDBWRITER | ESTDBCREAT):
        self.estdb = est_db_open(name, omode, &self._ecode)

    def close(self):
        if self.estdb != NULL:
            est_db_close(self.estdb, &self._ecode)
            self.estdb = NULL

    def _check(self):
        """
        Check that the connection has not been close already.
        """
        if self.estdb == NULL:
            raise HyperEstraierError('Database is closed.')

    property name:
        def __get__(self):
            self._check()
            return est_db_name(self.estdb)

    property size:
        def __get__(self):
            self._check()
            return est_db_size(self.estdb)

    property ecode:
        def __get__(self):
            self._check()
            return est_err_msg(self._ecode)

    property efatal:
        def __get__(self):
            self._check()
            return bool(est_db_fatal(self.estdb))

    property used_cache:
        def __get__(self):
            self._check()
            return est_db_used_cache_size(self.estdb)
    
    property records_in_cache:
        def __get__(self):
            self._check()
            return est_db_cache_num(self.estdb)

    def __len__(self):
        self._check()
        return est_db_doc_num(self.estdb)

    def put_doc(self, Document doc):
        self._check()
        est_db_put_doc(self.estdb, doc.estdoc, ESTPDCLEAN)

    def get_doc(self, int id, int options = 0):
        cdef ESTDOC *doc_p
        cdef Document doc
        self._check()
        doc_p = est_db_get_doc(self.estdb, id, options)
        if doc_p != NULL:
            doc = Document()
            doc.estdoc = doc_p
            return doc
        return None

    def get_doc_by_uri(self, uri):
        cdef int id
        self._check()
        id = est_db_uri_to_id(self.estdb, uri)
        return self.get_doc(id)

    def flush(self, int max = 0):
        self._check()
        if est_db_flush(self.estdb, max):
            return True
        raise DBFlushError("Wasn't able to flush the database.")

    def sync(self):
        self._check()
        if est_db_sync(self.estdb):
            return True
        raise DBSyncError("Wasn't able to sync the database.")

    def optimize(self, int options = 0):
        self._check()
        if est_db_optimize(self.estdb, options):
            return True
        raise DBOptimizeError("Wasn't able to optimize the database.")

    def search(self, phrase=None, simple=False):
        self._check()
        return Search(self, phrase, simple)

    def commit(self, Document doc):
        self._check()
        if est_db_edit_doc(self.estdb, doc.estdoc):
            return True
        raise DBEditError("Error while editing an object")

    def remove(self, Document doc , int options = ESTODCLEAN):
        self._check()
        if est_db_out_doc(self.estdb, doc.id, options):
            return True
        raise DBRemoveError("Error while removing an object")

    def set_cache_size(self, unsigned long size, anum, tnum, rnum):
        est_db_set_cache_size(self.estdb, size, anum, tnum, rnum)

    def set_special_cache_size(self, name, num):
        est_db_set_special_cache(self.estdb, name, num)

cdef class Search:
    """
    Search provides a way to search for, order and limit indexed documents.

    A Search instance is never created directly, an instance is created and
    returned by calling database.search().

    Search supports the iterator and len protocols as expected, as well as index
    and slice __getitem__ access.

    Search also provides methods to modify the set of documents returned by the
    search.
    """

    cdef Database database
    cdef Condition condition
    cdef int results_len
    cdef int *results

    def __new__(self, database, phrase, simple):
        self.database = database
        self.condition = Condition()
        if phrase is not None:
            self.condition.set_phrase(phrase)
        if simple:
            self.condition.set_options(ESTCONDSIMPLE)

    def __dealloc__(self):
        if self.results != NULL:
            free(self.results)
            self.results = NULL

    def max(self, max):
        """
        Set the maximum number of documents returned by the search.
        """
        self.condition.set_max(max)
        return self

    def add(self, expr):
        """
        Add an attribute expression.
        """
        self.condition.add_attr(expr)
        return self

    def order(self, expr):
        """
        Set the ordering expression.
        """
        self.condition.set_order(expr)
        return self

    def __getitem__(self, s):
        """
        Return an item or slice of the results as one or a sequence of
        Document instances.
        """
        self.prepare()
        if isinstance(s, slice):
            return SearchIterator(self, *s.indices(self.results_len))
        else:
            return self.doc_at(s)

    def __len__(self):
        """
        Return the number of documents found by the search.
        """
        self.prepare()
        return self.results_len

    def __iter__(self):
        """
        Support the iterator protocol.
        """
        self.prepare()
        return SearchIterator(self, 0, self.results_len, 1)

    def prepare(self):
        """
        Prepare the finder for returning results. This executes the search if
        necessary and initialises any attributes needed to support further
        calls.
        """
        if self.results == NULL:
            self.results = est_db_search(
                self.database.estdb,
                self.condition.estcond,
                &self.results_len,
                NULL)

    def doc_at(self, pos):
        """
        Return the document at the given index position.
        """
        if pos < 0 or pos >= self.results_len:
            raise IndexError()
        docid = self.results[pos]
        return self.database.get_doc(docid)

class SearchIterator(object):

    def __init__(self, Search search, start, stop, stride):
        self.search = search
        self.start = start
        self.stop = stop
        self.stride = stride
        self.current = start

    def __iter__(self):
        return self

    def next(self):
        # Check there's actually something to iterate
        if self.start == self.stop:
            raise StopIteration()
        # Check the direction of the stride
        if (self.stop>self.start and self.stride<0) or (self.stop<self.start and self.stride>0):
            raise StopIteration()
        # Check if we've reached the stop index
        if self.current == self.stop:
            raise StopIteration()
        doc = self.search.doc_at(self.current)
        self.current = self.current + self.stride
        return doc


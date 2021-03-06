from dateutil.parser import parse

__version__ = "Hype version 0.01"

__herequired__ = "1.3.3"

cdef extern from 'Python.h':
    object PyString_FromString(char *str)

cdef extern from 'stdlib.h':
    void free(void *)

ESTDBREADER = 1 << 0      # open as a reader
ESTDBWRITER = 1 << 1      # open as a writer
ESTDBCREAT = 1 << 2       # a writer creating
ESTDBTRUNC = 1 << 3       # a writer truncating
ESTDBNOLCK = 1 << 4       # open without locking
ESTDBLCKNB = 1 << 5       # lock without blocking
ESTDBPERFNG = 1 << 6      # use perfect N-gram analyzer
ESTDBCHRCAT = 1 << 11     # use character category analyzer
ESTDBLARGE = 1 << 20      # large tuning (more than 300000 documents)
ESTDBHUGE = 1 << 21       # huge tuning (more than 1000000 documents)
ESTDBSCVOID = 1 << 25     # store scores as void
ESTDBSCINT = 1 << 26      # store scores as integer
ESTDBSCASIS = 1 << 27     # refrain from adjustment of scores

ESTCONDSURE = 1 << 0      # check every N-gram key
ESTCONDUSUAL = 1 << 1     # check N-gram keys skipping by one
ESTCONDFAST = 1 << 2      # check N-gram keys skipping by two
ESTCONDAGITO = 1 << 3     # check N-gram keys skipping by three
ESTCONDNOIDF = 1 << 4     # without TF-IDF tuning
ESTCONDSIMPLE = 1 << 10   # with the simplified phrase
ESTCONDSCFB = 1 << 30     # feed back scores (for debug)

ESTPDCLEAN = 1 << 0       # clean up dispensable regions
ESTPDWEIGHT = 1 << 1      # weight scores statically when indexing

ESTGDNOATTR = 1 << 0      # no attributes
ESTGDNOTEXT = 1 << 1      # no text

ESTOPTNOPURGE = 1 << 0    # omit purging dispensable region of deleted
ESTOPTNODBOPT = 1 << 1    # omit optimization of the database files

ESTODCLEAN = 1 << 0       # clean up dispensable regions

ESTIDXATTRSEQ = 0         # for multipurpose sequencial access method
ESTIDXATTRSTR = 1         # for narrowing with attributes as strings
ESTIDXATTRNUM = 2         # for narrowing with attributes as numbers

ESTENOERR = 9992          # no error
ESTEINVAL = 9993          # invalid argument
ESTEACCES = 9994          # access forbidden
ESTELOCK = 9995           # lock failure
ESTEDB = 9996             # database problem
ESTEIO = 9997             # I/O problem
ESTENOITEM = 9998         # no item
ESTEMISC = 9999           # miscellaneous

ESTRPSTRICT = 1 << 0      # perform strict consistency check
ESTRPSHODDY = 1 << 1      # omit consistency check

ESTMGCLEAN = 1 << 0       # clean up dispensable regions

ESTECLSIMURL = 10.0       # eclipse considering similarity and URL
ESTECLSERV = 100.0        # eclipse on server basis
ESTECLDIR = 101.0         # eclipse on directory basis
ESTECLFILE = 102.0        # eclipse on file basis

cdef extern from 'estraier.h':
    ctypedef struct CBMAP:
        pass

    ctypedef struct CBLIST:
        pass

    ctypedef struct ESTDB:
        pass

    ctypedef struct ESTDOC:
        pass

    ctypedef struct ESTCOND:
        pass

    char *est_version

    void cblistclose(CBLIST *list)                          # close cblist
    int cblistnum(CBLIST *list)                             # length of cblist
    char *cblistval(CBLIST *list, int index, int *sp)       # get value
    void cblistsort(CBLIST *list)                           # obvious

    CBMAP *cbmapopen()
    int cbmapput(CBMAP *map, char *kbuf, int ksiz, char *vbuf, int vsiz, int over)
    CBLIST *cbmapkeys(CBMAP *map)
    CBLIST *cbmapvals(CBMAP *map)
    void cbmapclose(CBMAP *map)

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
    int est_db_out_doc(ESTDB *db, int id, int options)
    int est_db_edit_doc(ESTDB *db, ESTDOC *doc)
    int est_db_error(ESTDB *db)
    int est_db_fatal(ESTDB *db)
    char *est_db_get_doc_attr(ESTDB *db, int id, char *name)
    int est_db_add_attr_index(ESTDB *db, char *name, int type)
    # int est_db_put_keywords(ESTDB *db, int id, CBMAP *kwords) In python
    # CBMAP *est_db_get_keywords(ESTDB *db, int id) In python
    int est_db_out_keywords(ESTDB *db, int id)
    CBMAP *est_db_etch_doc(ESTDB *db, ESTDOC *doc, int max)
    int *est_db_keyword_search(ESTDB *db, char *word, int *nump)

    # Advanced DB API
    int est_db_merge(ESTDB *db, char *name, int options)
    int est_db_cache_num(ESTDB *db)
    int est_db_used_cache_size(ESTDB *db)
    void est_db_set_special_cache(ESTDB *db, char *name, int num)
    void est_db_set_cache_size(ESTDB *db, int size, int anum, int tnum, int rnum)
    int est_db_repair(char *name, int options, int *ecp)
    int est_db_scan_doc(ESTDB *db, ESTDOC *doc, ESTCOND *cond)
    int est_db_inode(ESTDB *db)

    # DB TODO
    int est_db_set_doc_entity(ESTDB *db, int id, char *ptr, int size)
    char *est_db_get_doc_entity(ESTDB *db, int id, int *sp)
    void est_db_add_meta(ESTDB *db, char *name, char *value)
    CBLIST *est_db_meta_names(ESTDB *db)
    char *est_db_meta(ESTDB *db, char *name)
    int *est_db_search_meta(ESTDB **dbs, int dbnum, ESTCOND *cond, int *nump, CBMAP *hints)
    int est_db_measure_doc(ESTDB *db, int id, int parts)
    int est_db_iter_init(ESTDB *db, char *prev)
    int est_db_iter_next(ESTDB *db)
    int est_db_word_iter_init(ESTDB *db)
    char *est_db_word_iter_next(ESTDB *db)
    int est_db_word_rec_size(ESTDB *db, char *word)
    int est_db_keyword_num(ESTDB *db)
    int est_db_keyword_iter_init(ESTDB *db)
    char *est_db_keyword_iter_next(ESTDB *db)
    int est_db_keyword_rec_size(ESTDB *db, char *word)
    void est_db_fill_key_cache(ESTDB *db)
    void est_db_refresh_rescc(ESTDB *db)
    void est_db_charge_rescc(ESTDB *db, int max)
    CBLIST *est_db_list_rescc(ESTDB *db)
    void est_db_interrupt(ESTDB *db)
    CBLIST *est_hints_to_words(CBMAP *hints)
    void est_db_set_wildmax(ESTDB *db, int num)

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
    void est_doc_set_keywords(ESTDOC *doc, CBMAP *kwords)
    CBMAP *est_doc_keywords(ESTDOC *doc)
    int est_doc_is_empty(ESTDOC *doc)
    ESTDOC *est_doc_dup(ESTDOC *doc)
    void est_doc_set_score(ESTDOC *doc, int score)

    ## Document TODO
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
    char *est_cond_order(ESTCOND *cond)
    int est_cond_max(ESTCOND *cond)
    char *est_cond_phrase(ESTCOND *cond)
    int est_cond_options(ESTCOND *cond)
    int est_cond_score(ESTCOND *cond, int index)
    void est_cond_set_eclipse(ESTCOND *cond, double limit)
    CBLIST *est_cond_attrs(ESTCOND *cond)
    int *est_cond_shadows(ESTCOND *cond, int id, int *np)
    void est_cond_set_skip(ESTCOND *cond, int skip)
    int est_cond_skip(ESTCOND *cond)
    ESTCOND *est_cond_dup(ESTCOND *cond)
    int est_cond_mask(ESTCOND *cond)
    void est_cond_set_mask(ESTCOND *cond, int mask)

    # int est_cond_auxiliary(ESTCOND *cond) Breaks Win32 as of 1.1.1
    # void est_cond_set_auxiliary(ESTCOND *cond, int min) Breaks Win32 as of 1.1.1
    # int est_cond_auxiliary_word(ESTCOND *cond, char *word) Breaks Win32 as of 1.1.1
    
    # TODO
    void est_cond_set_expander(ESTCOND *cond, void (*func)(char *, CBLIST *))
    void est_db_set_informer(ESTDB *db, void (*func)(char *, void *), void *opaque)

EST_VERSION = PyString_FromString(est_version)

class HyperEstraierError(Exception):
    pass

class DBError(HyperEstraierError):
    pass

class DocumentError(HyperEstraierError):
    pass

class DocumentUnicodeError(DocumentError):
    pass

class DocModifyImmutableError(DocumentError):
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

class DBRepairError(DBError):
    pass

class DBAddAttributeIndexError(DBError):
    pass

class DBMergeError(DBError):
    pass

class DBRemoveKeywordsError(DBError):
    pass

cdef class Database # Forward
cdef class Search # Forward
cdef class Document # Forward

def dt_to_str(dt, iso=True):
    if iso:
        # "%Y-%m-%dT%H:%M:%SZ%z"
        return unicode(dt.isoformat())
    # RFC2822 
    # strftime uses the locale and translates the names which is bad.
    # print dt.strftime('%a, %d %b %Y %H:%M:%S %z').strip()
    res = "%s, %02d %s %04d %02d:%02d:%02d" % (
            ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][dt.isoweekday()-1],
            dt.day,
            ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
             "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][dt.month-1],
             dt.year, dt.hour, dt.minute, dt.second)
    return unicode(res)

def dt_from_str(date):
    return parse(date)

def _pass(obj):
    return obj

IN, OUT = range(2)
_filters = {'@mdate': (dt_to_str, dt_from_str),
            '@adate': (dt_to_str, dt_from_str),
            '@cdate': (dt_to_str, dt_from_str),
            '@size': (unicode, int),
            '@weight': (unicode, float),
            }

cdef object cbmap_to_dict(CBMAP *cm):
    cdef CBLIST *klist, *vlist
    cdef char *key, *val
    cdef int l, i, sp1, sp2

    keywords = {}

    klist = cbmapkeys(cm)
    vlist = cbmapvals(cm)

    l = cblistnum(klist)
    for i from 0 <= i < l:
        key = cblistval(klist, i, &sp1)
        val = cblistval(vlist, i, &sp2)
        keywords[decode(key)] = int(val)

    cblistclose(vlist)
    cblistclose(klist)
    return keywords

cdef CBMAP *dict_to_cbmap(d, CBMAP *cbmap):
    cdef int kwlen
    kw = d.items()
    kwlen = len(kw)
    for i from 0 <= i < kwlen:
        key = encode(kw[i][0])
        val = str(kw[i][1])
        cbmapput(cbmap, key, -1, val, -1, 1)
    return cbmap

cdef object cblist_to_list(CBLIST *cl):
    cdef int sp, cl_length, i
    cl_length = cblistnum(cl)
    l = []
    for i from 0 <= i < cl_length:
        l.append(cblistval(cl, i, &sp))
    return l

cdef list_to_cblist(l, CBLIST *cl):
    pass

def encode(unicode_string):
    if not isinstance(unicode_string, unicode):
        raise DocumentUnicodeError("Hype only accepts unicode text as input")
    return unicode_string.encode('utf-8')

def decode(encoded_string):
    # Since we only insert utf-8 encoded strings we can safely assume we 
    # will only ever decode utf-8 encoded strings
    return encoded_string.decode('utf-8')

def repair(char *path, int options):
    cdef int ecp
    if est_db_repair(path, options, &ecp):
        return True
    raise DBRepairError("Error while repairing the database: %d" % ecp)

cdef Document create_document(ESTDOC *edoc):
    cdef Document doc
    doc = Document(None, _nodoc=True)
    doc.estdoc = edoc
    return doc

cdef class Document:
    cdef ESTDOC *estdoc

    def __dealloc__(self):
        if self.estdoc != NULL:
            est_doc_delete(self.estdoc)
            self.estdoc = NULL

    def __init__(self, uri, _nodoc=False):
        if _nodoc is False:
            self.estdoc = est_doc_new()
            self['@uri'] = uri

    cdef check(self):
        if self.estdoc == NULL:
            raise DocumentError("Document not correctly initialized, None passed as initial argument")

    property id:
        " Document ID "
        def __get__(self):
            self.check()
            return est_doc_id(self.estdoc)
        
        def __set__(self, int id):
            self.check()
            est_doc_set_id(self.estdoc, id)

    property uri:
        def __get__(self):
            return self.get('@uri')

    property score:
        def __set__(self, score):
            """ Sets substitute score """
            self.check()
            est_doc_set_score(self.estdoc, score)

    property attributes:
        " A list of attribute names "
        def __get__(self):
            self.check()
            cdef CBLIST *attrs_c
            cdef int attrs_length, i, sp
            attrs_c = est_doc_attr_names(self.estdoc)
            cblistsort(attrs_c)
            attrs = cblist_to_list(attrs_c)
            cblistclose(attrs_c)
            return attrs

    property texts:
        " A list of texts in the document "
        def __get__(self):
            self.check()
            cdef CBLIST *_texts
            texts = []
            for text in cblist_to_list(est_doc_texts(self.estdoc)):
                texts.append(text.decode("utf-8"))
            # We don't need to close the list since its life is already
            # synchronous with the life of the document
            return texts

    property text:
        " A concatenated list of the texts in the document "
        def __get__(self):
            return unicode(' ').join(self.texts)
            
    property hidden_text:
        " A concatenated string of hidden text "
        def __get__(self):
            self.check()
            # See above, we don't need to worry about lifetime here too
            decoded = decode(est_doc_hidden_texts(self.estdoc))
            return decoded

    def __getitem__(self, name):
        value = self.get(name)
        if value is not None:
            return value
        raise KeyError('Document has no attribute %r'%name)

    def __setitem__(self, name, value):
        if name == "@uri" and self.get('@uri', None):
            raise DocModifyImmutableError("Cannot modify @uri attribute")
        if not isinstance(value, basestring):
            value = _filters.get(name, (unicode, _pass))[IN](value)
        encoded = encode(value)
        est_doc_add_attr(self.estdoc, name, encoded)

    def is_empty(self):
        self.check()
        return bool(est_doc_is_empty(self.estdoc))

    def copy(self):
        self.check()
        cdef ESTDOC *doc_p
        cdef Document doc
        doc_p = est_doc_dup(self.estdoc)
        doc = create_document(doc_p)
        return doc

    def get(self, name, default=None):
        self.check()
        cdef char *value
        value = est_doc_attr(self.estdoc, name)
        if value == NULL:
            return default
        decoded = decode(value)
        return _filters.get(name, (_pass, _pass))[OUT](decoded)

    def add_text(self, text):
        self.check()
        encoded = encode(text)
        est_doc_add_text(self.estdoc, encoded)

    def add_hidden_text(self, text):
        self.check()
        encoded = encode(text)
        est_doc_add_hidden_text(self.estdoc, encoded)

    def set_keywords(self, kwdict):
        self.check()
        cdef CBMAP *cbmap
        cbmap = cbmapopen()
        dict_to_cbmap(kwdict, cbmap)
        est_doc_set_keywords(self.estdoc, cbmap)

    def get_keywords(self):
        self.check()
        cdef CBMAP *cbmap
        cbmap = est_doc_keywords(self.estdoc)
        if cbmap != NULL:
            d = cbmap_to_dict(cbmap)
            return d
        return {}

def doc_from_string(char *data):
    cdef ESTDOC *doc_p
    cdef Document doc
    encoded = encode(data)
    doc_p = est_doc_new_from_draft(encoded)
    doc = create_document(doc_p)
    return doc

cdef class Condition:
    cdef ESTCOND *estcond

    def __new__(self):
        self.estcond = est_cond_new()

    property max:
        def __get__(self):
            return est_cond_max(self.estcond)
        def __set__(self, max):
            self.set_max(max)
    
    property phrase:
        def __get__(self):
            return est_cond_phrase(self.estcond)
        def __set__(self, phrase):
            self.set_phrase(phrase)
    
    property order:
        def __get__(self):
            return est_cond_order(self.estcond)
        def __set__(self, order):
            self.set_order(order)
    
    property offset:
        def __get__(self):
            return est_cond_skip(self.estcond)
        def __set__(self, off):
            self.set_offset(off)
    
    property options:
        def __get__(self):
            return est_cond_options(self.estcond)
        def __set__(self, int options):
            self.set_options(options)
    
    property mask:
        def __get__(self):
            return est_cond_mask(self.estcond)
        def __set__(self, int mask):
            self.set_mask(mask)
    
    property eclipse:
        def __set__(self, double limit):
            self.set_eclipse(limit)

    property attrs:
        def __get__(self):
            cdef CBLIST *_attrs
            cdef int _attrs_length, i, sp
            _attrs = est_cond_attrs(self.estcond)
            return cblist_to_list(_attrs)
            # We don't need to close the list since its life is already
            # synchronous with the life of the condition

    #property aux:
    #    def __get__(self):
    #        return est_cond_auxiliary(self.estcond)
    #    def __set__(self, min):
    #        est_cond_set_auxiliary(self.estcond, min)

    #def aux_used(self, word):
    #    return bool(est_cond_auxiliary_word(self.estcond, word))

    def get_score(self, index):
        return est_cond_score(self.estcond, index)

    def set_eclipse(self, double limit, criteria=ESTECLSIMURL):
        est_cond_set_eclipse(self.estcond, limit+criteria)
    
    def copy(self):
        cdef ESTCOND *cond_p
        cdef Condition cond
        cond_p = est_cond_dup(self.estcond)
        cond = Condition()
        cond.estcond = cond_p
        return cond

    def set_phrase(self, phrase):
        encoded = encode(phrase)
        est_cond_set_phrase(self.estcond, encoded)

    def add_attr(self, attr):
        encoded = encode(attr)
        est_cond_add_attr(self.estcond, encoded)

    def set_order(self, order):
        encoded = encode(order)
        est_cond_set_order(self.estcond, encoded)

    def set_max(self, int max):
        est_cond_set_max(self.estcond, max)
    
    def set_offset(self, int off):
        est_cond_set_skip(self.estcond, off)

    def set_options(self, int options):
        est_cond_set_options(self.estcond, options)
    
    def set_mask(self, int mask):
        est_cond_set_mask(self.estcond, mask)

    def __dealloc__(self):
        est_cond_delete(self.estcond)

cdef class Database:
    cdef ESTDB *estdb
    cdef int _ecode

    def __new__(self, name, omode=ESTDBWRITER | ESTDBCREAT | ESTDBSCASIS):
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

    property inode:
        def __get__(self):
            self._check()
            return est_db_inode(self.estdb)

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
            doc = create_document(doc_p)
            return doc
        return None

    def get_doc_by_uri(self, uri):
        cdef int id
        self._check()
        encoded = encode(uri)
        id = est_db_uri_to_id(self.estdb, encoded)
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

    def keyword_search(self, words):
        cdef int *results
        cdef int results_len
        results = est_db_keyword_search(self.estdb, words, &results_len)
        res = []
        for i from 0 <= i < results_len:
            res.append(self.get_doc(results[i]))
        free(results)
        return res

    def commit(self, Document doc):
        self._check()
        if est_db_edit_doc(self.estdb, doc.estdoc):
            return True
        raise DBEditError("Error while editing object %s" % (doc.id,))

    def remove(self, Document doc , int options = ESTODCLEAN):
        self._check()
        if est_db_out_doc(self.estdb, doc.id, options):
            return True
        raise DBRemoveError("Error while removing object %s" % (doc.id,))

    def add_attr_index(self, name, type):
        self._check()
        if est_db_add_attr_index(self.estdb, name, type):
            return True
        raise DBAddAttributeIndexError("Error while adding attribute index %s" % (name,))

    def merge(self, path, int options = ESTMGCLEAN):
        self._check()
        if est_db_merge(self.estdb, path, options):
            return True
        raise DBMergeError("Error while merging database %s" % (path,))

    def get_doc_attr(self, int id, name):
        self._check()
        return est_db_get_doc_attr(self.estdb, id, name)

    def scan_doc(self, Document doc, Search search):
        self._check()
        return bool(est_db_scan_doc(self.estdb, doc.estdoc, search.condition.estcond))

    def put_keywords_in(self, id, kwdict):
        doc = self.get_doc(id)
        doc.set_keywords(kwdict)

    def get_keywords_from(self, id):
        doc = self.get_doc(id)
        return doc.get_keywords()

    def remove_keywords_from(self, id):
        if est_db_out_keywords(self.estdb, id):
            return True
        raise DBRemoveKeywordsError("Error while removing keywords from %s" % (id,))

    def etch(self, Document doc, int max):
        cdef CBMAP *cbmap
        cbmap = est_db_etch_doc(self.estdb, doc.estdoc, max)
        d = cbmap_to_dict(cbmap)
        return d

    def set_cache_size(self, unsigned long size, anum, tnum, rnum):
        self._check()
        est_db_set_cache_size(self.estdb, size, anum, tnum, rnum)

    def set_special_cache_size(self, name, num):
        self._check()
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
    cdef int _scores
    cdef object sc

    def __new__(self, database, phrase, simple):
        self.database = database
        self.condition = Condition()
        if phrase is not None:
            self.condition.set_phrase(phrase)
        if simple:
            self.condition.set_options(ESTCONDSIMPLE)
        self._scores = 0
        self.sc = []

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

    def offset(self, off):
        """
        Set the offset of the result list returned by the search
        """
        self.condition.set_offset(off)
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
    
    def mask(self, mask):
        """
        Set the mask for the condition when metasearch is used.
        """
        self.condition.set_mask(mask)
        return self
    
    def eclipse(self, double limit, criteria=ESTECLSIMURL):
        """ Set the lower limit of similarity eclipse """
        self.condition.set_eclipse(limit, criteria)
        return self

    def scores(self):
        """ Enabling returning the scores togheter with the documents """
        self._scores = 1
        return self

    def shadows(self, Document doc):
        cdef int* _res
        cdef int np, i
        res = []
        _res = est_cond_shadows(self.condition.estcond, doc.id, &np)
        i = 0
        while i < np:
            res.append((self.database.get_doc(_res[i]), _res[i+1]))
            i = i + 2
        return res

    def option(self, int opt):
        self.condition.set_options(opt)
        return self

    def get_score(self, int index):
        return self.sc[index]

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
        cdef int i
        if self.results == NULL:
            self.results = est_db_search(
                self.database.estdb,
                self.condition.estcond,
                &self.results_len,
                NULL)
            if self._scores:
                for i from 0 <= i < self.results_len:
                    self.sc.append(self.condition.get_score(i))

    def doc_at(self, pos):
        """
        Return the document at the given index position.
        """
        if pos < 0 or pos >= self.results_len:
            raise IndexError()
        docid = self.results[pos]
        doc = self.database.get_doc(docid)
        if self._scores == 1:
            score = self.get_score(pos)
            return doc, score
        else:
            return doc

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




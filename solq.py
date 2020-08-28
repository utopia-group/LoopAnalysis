### UToPiA Solidity Refactoring
### Ronak Ramachandran
### For regex debugging, see: https://www.debuggex.com/

import os
import sys
import re

readme = '''
 How to use solq.py:
╔═══════════════════════════════════════════════════════════════════════════╗
║ 1. Copy the original contract (eg. ContractName.sol) into the directory   ║
║    you want to work within (preferably empty)                             ║
║                                                                           ║
║ 2. Make another copy and rename it "template.sol"                         ║
║                                                                           ║
║ 3. Edit template.sol so that the structs are organized the way you want   ║
║                                                                           ║
║    Use the following naming convention:                                   ║
║     - If you want to unwrap struct A, just rename it A_UNWRAP             ║
║     - If you split struct A, rename the split parts A_1, A_2 ...          ║
║     - If you want to wrap certain mappings into a new struct named A,     ║
║       add the suffix "_WRAPasA" to the end of each identifier             ║
║     - [NOT IMPLEMENTED] If you merge A and B, rename the combined         ║
║       contract A_B                                                        ║
║     - Feel free to do reorders along the way, but don't change any        ║
║       field names or types (except for the WRAPasX suffix)                ║
║                                                                           ║
║    You can do multiple transformations at once, but it may help to        ║
║    limit yourself to a few at a time                                      ║
║                                                                           ║
║ 4. Run this in your terminal and pass the original contract file as an    ║
║    argument (You may want to add solq.py to your path variable):          ║
║                                                                           ║
║        >>> solq.py ContractName.sol                                       ║
║        Flags: -v for verbose output                                       ║
║                                                                           ║
║    CAUTION: This will overwrite the file ContractNameT.sol                ║
╚═══════════════════════════════════════════════════════════════════════════╝'''
verbose = False
array_depth = 2

### TIPS:
# - Don't use the same identifier for fields in different structs
# - Try to avoid underscores in identifiers
# - It may help to run one transformation at a time

### NICHE ISSUES:
# - During Unwrap, .push and .length on arrays/maps tend to mess things up 
# - Wrap and Unwrap can result in race conditions if you try to do both at once
# - Wrap only works on mappings from the same key type
# - Mapping identifiers need to be unique for wrap to work (there can't be struct fields with the same identifier, for instance)

# = CLASSES ======================================


class Struct:
    def __init__(self, name, fields):
        self.name = name
        self.fields = fields

    def __str__(self):
        fields_s = ''
        for f in self.fields:
            fields_s += '\t' + str(f) + '\n'
        return 'struct ' + self.name + ' {\n' + fields_s + '}'

    def __eq__(self,obj):
        return (isinstance(obj,Struct)
                and len(self.fields) == len(obj.fields)
                and all(self.fields[i] == obj.fields[i] for i in range(len(self.fields))))
    

class Field:
    def __init__(self, tao, ident):
        self.type = tao
        self.ident = ident

    def __str__(self):
        return self.type + ' ' + self.ident + ';'

    def __eq__(self, obj):
        return (isinstance(obj,Field)
                and self.type == obj.type
                and self.ident == obj.ident)
    

class Reorder:
    def __init__(self, name):
        self.name = name
        self.field_order = []
        self.__verify_validity()

    def __str__(self):
        return f"Reorder({self.name})"

    def __verify_validity(self):
        o_struct = o_structs[self.name]
        t_struct = t_structs[self.name]
        
        for f in t_struct.fields:
            if f not in o_struct.fields:
                throw_not_found_in(self, f, "original")
            index = o_struct.fields.index(f)
            self.field_order.append(index)

        if len(o_struct.fields) != len(t_struct.fields):
            throw_not_found_in(self, "some fields in original", "template")

    def o_args_to_t_args(self, o_args):
        for i,f in enumerate(o_structs[self.name].fields):
            if 'mapping' in f.type or '[' in f.type: #arrays are ignored in constructor
                o_args.insert(i,None)
        assert(len(o_args) == len(o_structs[self.name].fields))
        
        t_args = list(filter(None, (o_args[i] for i in self.field_order)))
        return t_args


class Unwrap:
    def __init__(self, name):
        self.name = name
        self.fields = o_structs[self.name].fields
        self.constructor_field_names = list(
            f.ident for f in filter(
                lambda x : '[' not in x.type and 'mapping' not in x.type,
                o_structs[self.name].fields))

    def __str__(self):
        return f"Unwrap({self.name})"


class Split:
    
    def __init__(self, name, n):
        self.name = name
        self.n = n
        self.field_map = {}
        self.field_order = []
        self.__verify_validity()

    def __str__(self):
        return f"Split({self.name}, {self.n})"

    def __verify_validity(self):
        '''also initializes self.field_map and self.field order'''
        if self.name not in o_structs:
            throw_not_found_in(self, self.name, "original")
            
        o_struct = o_structs[self.name]
        seen = [False]*len(o_struct.fields)
        
        for i in range(1,self.n+1):
            if self.name + "_" + str(i) not in t_structs:
                throw_not_found_in(self, self.name + "_" + str(i), "template")
                
            t_struct = t_structs[self.name + "_" + str(i)]

            self.field_order.append([])
            
            for f in t_struct.fields:
                if f not in o_struct.fields:
                    throw_not_found_in(self, f, "original")
                
                index = o_struct.fields.index(f)
                
                if seen[index]:
                    print(str(self), "not a valid split:", f, "duplicated in template.")
                    exit(1)
                seen[index] = True

                self.field_map[f.ident] = i
                self.field_order[-1].append(index)
                
        if not all(seen):
            throw_not_found_in(self, o_struct.fields[seen.index(False)], "template")

    def get_struct_containing(self, field_name):
        return self.field_map[field_name]

    def o_args_to_t_args(self, o_args):
        for i,f in enumerate(o_structs[self.name].fields):
            if 'mapping' in f.type or '[' in f.type: #arrays are ignored in constructor
                o_args.insert(i,None)
        assert(len(o_args) == len(o_structs[self.name].fields))
        
        t_args = []
        for t_struct in self.field_order:
            t_args.append(list(filter(None, (o_args[f] for f in t_struct))))
        return t_args

class Wrap:
    def __init__(self, name, tao, ident, key_type, scope):
        self.struct = Struct(name, [Field(tao, ident)])
        self.key_type = key_type
        self.scope = scope

    def __str__(self):
        return f"Wrap({self.struct.name}, {len(self.struct.fields)})"

    def add_field(self, tao, ident, key_type, scope):
        if self.key_type != key_type:
            print(f"{self} not a valid wrap: key type for {ident} does not match key type for {self.struct.fields[0].ident}.")
            exit(1)
        if self.scope != scope:
            print(f"{self} not a valid wrap: scope of {ident} does not match scope of {self.struct.fields[0].ident}.")
            exit(1)
        self.struct.fields.append(Field(tao, ident))


class Merge:
    def __init__(self, a, b):
        self.a = a
        self.b = b
        self.__verify_validity()

    def __str__(self):
        return f"Merge({self.a}, {self.b})"

    def __verify_validity(self):
        if self.a + "_" + self.b not in t_structs:
            throw_not_found_in(self, self.a + "_" + self.b, "template")
            
        t_struct = t_structs[self.a + "_" + self.b]
        seen = [False]*len(t_struct.fields)

        if self.a not in o_structs:
            throw_not_found_in(self, self.a, "original")
        if self.b not in o_structs:
            throw_not_found_in(self, self.b, "original")

        for o_struct in [o_structs[self.a], o_structs[self.b]]:
            for f in o_struct.fields:
                if f not in t_struct.fields:
                    throw_not_found_in(self, f, "template")
                index = t_struct.fields.index(f)
                if seen[index]:
                    print(f"{self} not a valid merge: duplicate fields in original contracts.")
                    exit(1)
                seen[index] = True
            
        if not all(seen):
            throw_not_found_in(self, t_struct.fields[seen.index(False)], "original")


# = FUNCTIONS ====================================

#public
def get_structs(contract):
    '''Returns map(struct_name -> Struct)'''
    matches = re.findall("\n[^/\n]*struct\s+(\w+)\s*{([^}]*)}",contract)
    structs = {}
    
    for struct in matches:
        matches = re.findall("\n*[ \t\r\f\v]*(?P<type>[^;\n]*)\s+(?P<id>\w+)\s*;", struct[1])
        fields = []
        for m in matches:
            fields.append(Field(m[0], m[1]))
        structs[struct[0]] = Struct(struct[0], fields)
        
    return structs

#public
def get_wraps_and_clean(contract):
    wrap_seen = []
    wraps = {}
    
    def sub_clean_wraps(m):
        scope = get_surrounding_scope(contract, m.start())
        key_type, value_type = get_key_value_type(m.group('pre'))
        ident = m.group('id')
        name = m.group('name')
        
        if name not in wrap_seen:
            wrap_seen.append(name)
            wraps[name] = Wrap(name, value_type, ident, key_type, scope)
        else:
            wraps[name].add_field(value_type, ident, key_type, scope)
        
        return f"{m.group('ws')}{m.group('pre')}{m.group('id')}"
    
    contract = re.sub('(?P<ws>\n[ \t\r\f\v]*)(?P<pre>mapping\s*\([^)]*(?:\)\s*)*)(?P<id>\w+)_WRAPas(?P<name>\w+)',
                      sub_clean_wraps, contract)
        
    return contract, list(wraps.values())

#public
def get_transforms(contract, o_structs, t_structs):
    '''Returns a list of Split and Merge objects
with transformations based on the names of structs
in the original and template contracts. This method
will terminate if the transformations are invalid.'''
    transforms = {'REORDER':[],'UNWRAP':[],'SPLIT':[],'MERGE':[]}

    split_seen = []
    
    for s_name in t_structs:
        
        if s_name in o_structs:
            if t_structs[s_name] != o_structs[s_name]:
                transforms['REORDER'].append(Reorder(s_name))
            continue

        if '_' not in s_name:
            continue

        underscore = s_name.rfind('_')
        first_half = s_name[:underscore]
        second_half = s_name[underscore+1:]
        
        if first_half in split_seen:
            continue
        if second_half == 'UNWRAP':
            transforms['UNWRAP'].append(Unwrap(first_half))
        elif second_half.isdigit():
            split_seen.append(first_half)
            i = 1
            while first_half + '_' + str(i) in t_structs:
                i += 1
            transforms['SPLIT'].append(Split(first_half, i-1))
            
        else:
            transforms['MERGE'].append(Merge(first_half, second_half))
        
    return transforms


# - HELPER ---------------------------------------


def throw_not_found_in(t, item, contract_name):
    '''Helper method to throw error and exit
if item from transformation t not found in
original or template contract.'''
    print(f"{t} not a valid {type(t).__name__}: {item} not found in {contract_name}.")
    exit(1)


def end_of_next_index_access(s, i):
    assert(i >= len(s) or s[i] == '[')
    i += 1
    index_depth = 1
    while index_depth != 0:
        if s[i] == '[':
            index_depth += 1
        elif s[i] == ']':
            index_depth -= 1
        i += 1
    return i

def end_of_next_field_access(s, i):
    assert(i >= len(s) or s[i] == '.')
    i += 1
    while i < len(s) and re.match('\w', s[i]):
        i += 1
    return i

def skip_ws(s, i):
    while i < len(s) and re.match('\s', s[i]):
        i += 1
    return i


def get_key_value_type(mapping_decl):
    key_start = mapping_decl.index('(') + 1
    key_end = mapping_decl.index('=>')
    value_start = key_end + 2
    value_end = mapping_decl.rfind(')')
    return mapping_decl[key_start:key_end].strip(), mapping_decl[value_start:value_end].strip()

def get_surrounding_scope(s, i):
    open_brac = i + 1
    depth = 0
    while depth != -1:
        open_brac -= 1
        if open_brac == -1 or s[open_brac] == '{':
            depth -= 1
        elif s[open_brac] == '}':
            depth += 1
            
    close_brac = i - 1
    depth = 0
    while depth != -1:
        close_brac += 1
        if close_brac == len(s) or s[close_brac] == '}':
            depth -= 1
        elif s[close_brac] == '{':
            depth += 1
        
    return open_brac, close_brac

def get_top_level_contract(s, i):
    j = i
    while i >= 0:
        start,end = i,j
        i,j = get_surrounding_scope(s,i-1)
        
    return start, end
        

def replace_all_arr_decl(t, contract, id_depth_map, sub_arr_decl):
    size_tidbits = ''
    for depth in range(array_depth+1): #search for arrays of every depth up to max depth set by array_depth global var - zero depth arr corresponds to single var
        pattern = f"\n(?P<ws>[ \t\r\f\v]*){t.name}{size_tidbits}\s+(?P<flags>(?:\w+\s+)*)(?P<id>\w+)\s*;(?P<comment>[ \t\r\f\v]*//[^\n]*)?"
        contract = re.sub(pattern, lambda m : sub_arr_decl(m, depth), contract)
        size_tidbits = size_tidbits + f"\s*\[\s*(?P<size{depth}>[0-9]*)\s*\]"
        
    return contract

def replace_all_map_decl(t, contract, id_depth_map, sub_map_decl):
    map_format = "mapping\s*\(\s*(?P<key{keynum}>\w+)\s*=>\s*{value}\s*\)\s*"
    key_tidbits = "{0}"
    for depth in range(1,array_depth+1): #search for maps of every depth up to max depth set by array_depth global var - no zero depth maps
        key_tidbits = key_tidbits.format(map_format.format(keynum=depth,value='{0}')) #nest maps
        pattern = ("\n(?P<ws>[ \t\r\f\v]*)" + key_tidbits + "(?P<flags>(?:\w+\s+)*)(?P<id>\w+)\s*;(?P<comment>[ \t\r\f\v]*//[^\n]*)?").format(t.name)
        contract = re.sub(pattern, lambda m : sub_map_decl(m, depth), contract)
        
    return contract

def replace_all_arr_map_nest(t, contract, id_depth_map, sub_arr_map_nest):
    '''unwraps nested maps of an array of the appropriate struct'''
    map_format = "mapping\s*\(\s*(?P<key{keynum}>\w+)\s*=>\s*{value}\s*\)\s*"
    key_tidbits = "{0}"
    for depth in range(1,array_depth+1): #search for maps of every depth up to max depth set by array_depth global var - no zero depth maps
        key_tidbits = key_tidbits.format(map_format.format(keynum=depth,value='{0}')) #nest maps
        pattern = ("\n(?P<ws>[ \t\r\f\v]*)" + key_tidbits + "(?P<flags>(?:\w+\s+)*)(?P<id>\w+)\s*;(?P<comment>[ \t\r\f\v]*//[^\n]*)?").format(f"{t.name}\s*\[\s*(?P<size>[0-9]*)\s*\]")
        contract = re.sub(pattern, lambda m : sub_arr_map_nest(m, depth), contract)
        
    return contract

def replace_all_field_accesses(t, contract, id_depth_map, sub_field_access_return_format):
    def sub_field_access(m, ident, s):
        index_contents = []
        
        index_end = m.start('rest')
        for i in range(id_depth_map[ident]): #as many index accesses as depth of id
            index_start = skip_ws(s, index_end)
            if s[index_start] == '.': #.push or .length
                rest_of_line = m.group('rest')[index_start - m.start('rest'):]
                rest_of_line = replace_arr_usages(ident, rest_of_line) # circular recursion - watch out
                index_str = ''.join(('[' + i + ']') for i in index_contents)
                return f'{ident}{index_str}{rest_of_line}'
            index_end = end_of_next_index_access(s, index_start)
            index_content = s[index_start+1:index_end-1].strip()
            
            index_contents.append(replace_arr_usages(ident, index_content)) # circular recursion - watch out
            
        index_str = ''.join(('[' + i + ']') for i in index_contents)

        field_start = skip_ws(s, index_end)
        if field_start < len(s) and s[field_start] != '.':
            rest_of_line = m.group('rest')[index_end - m.start('rest'):]
            rest_of_line = replace_arr_usages(ident, rest_of_line) # circular recursion - watch out
            return f'{ident}{index_str}{rest_of_line}'
        field_end = end_of_next_field_access(s, field_start)
        field_name = s[field_start+1:field_end]

        rest_of_line = m.group('rest')[field_end - m.start('rest'):]

        rest_of_line = replace_arr_usages(ident, rest_of_line) # circular recursion - watch out

        return sub_field_access_return_format(ident, index_str, field_name, rest_of_line)

    def replace_arr_usages(ident, s):
        return re.sub("(?<=\W){0}(?P<rest>\s*\[[^;]*)".format(ident),
                      lambda m : sub_field_access(m, ident, s), s)
    
    for ident in id_depth_map:
        contract = replace_arr_usages(ident, contract)
        
    return contract

def sub_named_init_args(m, struct):
    args_str = m.group("args") + ','
    args = re.findall("(\w+)\s*:\s*([^,]*),", args_str)
    value_dict = {}
    for arg in args:
        value_dict[arg[0]] = arg[1].strip()
    return f'{struct.name}({", ".join(value_dict[f.ident] for f in struct.fields)})'
    

def flatten_named_initializers(struct, contract):
    return re.sub(f"(?<=\W){struct.name}\s*\(\s*{{\s*(?P<args>[^}}]*)\s*}}\s*\)",
           lambda m : sub_named_init_args(m, struct), contract)

def replace_all_constructors(t, contract, sub_constructor):
    contract = flatten_named_initializers(o_structs[t.name], contract)
    return re.sub(f"(?P<lhs>[^=\n]*)\s*=\s*{t.name}\((?P<args>[^)]*)\);", sub_constructor, contract)

def remove_struct(name, contract):
    return re.sub(f"[^/\n]*struct\s+{name}\s*{{([^}}]*)}}\n*", "", contract)


# = TRANSFORMATIONS ==============================

#public
def execute(t, contract):
    '''Executes transformation and returns new source text.'''
    if isinstance(t, Reorder):
        return reorder(t, contract)
    if isinstance(t, Unwrap):
        return unwrap(t, contract)
    if isinstance(t, Split):
        return split(t, contract)
    if isinstance(t, Wrap):
        return wrap(t, contract)
    if isinstance(t, Merge):
        return merge(t, contract)
    return contract


# - REORDER --------------------------------------

#public
def reorder(t, contract):
    '''Takes in a Reorder object and source text,
and returns source text after reorder.
This is a heuristic, and is not guaranteed to work.'''

    # Constructors
    def sub_constructor(m):
        lhs = m.group('lhs')
        args = m.group('args').split(',')
        id_end = lhs.index('[')
        if id_end == -1:
            id_end = len(lhs)
        t_args = t.o_args_to_t_args(args)
        return f'{lhs[:id_end]}{lhs[id_end:]}= {t.name}({",".join(t_args)});'
        
    replace_all_constructors(t, contract, sub_constructor)

    return contract


# - UNWRAP ---------------------------------------

#public
def unwrap(t, contract):
    '''Takes in an Unwrap object and source text,
and returns source text after unwrap.
This is a heuristic, and is not guaranteed to work.'''
    
    id_depth_map = {}
    
    def sub_arr_decl(m, depth):
        id_depth_map[m.group('id')] = depth
        size_tidbits = ''.join(filter(None, (('[' + m.group('size' + str(i)) + ']') for i in range(depth))))
        repl = ''.join(filter(None, ('\n', m.group('ws'), '{0}', size_tidbits ,' ', m.group('flags'), m.group('id'), '_{1};', m.group('comment'))))
        return ''.join(repl.format(f.type, f.ident) for f in t.fields)

    def sub_map_decl(m, depth):
        id_depth_map[m.group('id')] = depth
        key_tidbits = ''.join(filter(None, ( ('mapping(' + m.group('key' + str(i)) + ' => ') for i in range(1,depth+1) ) )) + "{0}" + (')'*depth)
        repl = ''.join(filter(None, ('\n', m.group('ws'), key_tidbits, ' ', m.group('flags'), m.group('id'), '_{1};', m.group('comment'))))
        return ''.join(repl.format(f.type, f.ident) for f in t.fields)

    def sub_arr_map_nest(m, m_depth):
        id_depth_map[m.group('id')] = m_depth + 1 #single array nested in maps
        key_tidbits = ''.join(filter(None, ( ('mapping(' + m.group('key' + str(i)) + ' => ') for i in range(1,m_depth+1) ) )) + "{0}" + f"[{m.group('size')}]" + (')'*m_depth)
        repl = ''.join(filter(None, ('\n', m.group('ws'), key_tidbits, ' ', m.group('flags'), m.group('id'), '_{1};', m.group('comment'))))
        return ''.join(repl.format(f.type, f.ident) for f in t.fields)

    def sub_field_access_return_format(ident, index_str, field_name, rest_of_line):
        return f'{ident}_{field_name}{index_str}{rest_of_line}'

    def sub_constructor(m):
        lhs = m.group('lhs')
        args = m.group('args').split(',')
        id_end = lhs.index('[')
        if id_end == -1:
            id_end = len(lhs)
        return '\n'.join(f'{lhs[:id_end]}_{f}{lhs[id_end:]}= {args[i]});' for i,f in enumerate(t.constructor_field_names))

    contract = replace_all_arr_decl(t, contract, id_depth_map, sub_arr_decl)
    contract = replace_all_map_decl(t, contract, id_depth_map, sub_map_decl)
    contract = replace_all_arr_map_nest(t, contract, id_depth_map, sub_arr_map_nest)
    contract = replace_all_field_accesses(t, contract, id_depth_map, sub_field_access_return_format)
    contract = remove_struct(f"{t.name}_UNWRAP", contract)
    contract = replace_all_constructors(t, contract, sub_constructor)
        
    return contract


# - SPLIT ----------------------------------------

#public
def split(t, contract):
    '''Takes in a t object and source text,
and returns source text after split.
This is a heuristic, and is not guaranteed to work.'''

    id_depth_map = {}
    
    def sub_arr_decl(m, depth):
        id_depth_map[m.group('id')] = depth
        size_tidbits = ''.join(filter(None, (('[' + m.group('size' + str(i)) + ']') for i in range(depth))))
        repl = ''.join(filter(None, ('\n', m.group('ws'), '{0}_{1}', size_tidbits ,' ', m.group('flags'), m.group('id'), '_{1};', m.group('comment'))))
        return ''.join(repl.format(t.name, i) for i in range(1,t.n+1))

    def sub_map_decl(m, depth):
        id_depth_map[m.group('id')] = depth
        key_tidbits = ''.join(filter(None, ( ('mapping(' + m.group('key' + str(i)) + ' => ') for i in range(1,depth+1) ) )) + "{0}_{1}" + (')'*depth)
        repl = ''.join(filter(None, ('\n', m.group('ws'), key_tidbits, ' ', m.group('flags'), m.group('id'), '_{1};', m.group('comment'))))
        return ''.join(repl.format(t.name, i) for i in range(1,t.n+1))

    def sub_arr_map_nest(m, m_depth):
        id_depth_map[m.group('id')] = m_depth + 1 #single array nested in maps
        key_tidbits = ''.join(filter(None, ( ('mapping(' + m.group('key' + str(i)) + ' => ') for i in range(1,m_depth+1) ) )) + "{0}_{1}" + f"[{m.group('size')}]" + (')'*m_depth)
        repl = ''.join(filter(None, ('\n', m.group('ws'), key_tidbits, ' ', m.group('flags'), m.group('id'), '_{1};', m.group('comment'))))
        return ''.join(repl.format(t.name, i) for i in range(1,t.n+1))

    def sub_field_access_return_format(ident, index_str, field_name, rest_of_line):
        n = t.get_struct_containing(field_name)
        return f'{ident}_{n}{index_str}.{field_name}{rest_of_line}'

    def sub_constructor(m):
        lhs = m.group('lhs')
        args = re.sub('\s','',m.group('args')).split(',')
        id_end = lhs.index('[')
        if id_end == -1:
            id_end = len(lhs)
        t_args = t.o_args_to_t_args(args)
        return '\n'.join(f'{lhs[:id_end]}_{i+1}{lhs[id_end:]}= {t.name}_{i+1}({", ".join(t_args[i])});' for i in range(t.n))
    
    contract = replace_all_arr_decl(t, contract, id_depth_map, sub_arr_decl)
    contract = replace_all_map_decl(t, contract, id_depth_map, sub_map_decl)
    contract = replace_all_arr_map_nest(t, contract, id_depth_map, sub_arr_map_nest)
    contract = replace_all_field_accesses(t, contract, id_depth_map, sub_field_access_return_format)
    contract = replace_all_constructors(t, contract, sub_constructor)
    
    return contract


# - WRAP -----------------------------------------


#public
def wrap(t, contract):
    '''Takes in a Wrap object and source text,
and returns source text after wrap.
This is a heuristic, and is not guaranteed to work.'''

    #refresh scope
    m = re.search(f'(?P<ws>\n[ \t\r\f\v]*)(?P<pre>mapping\s*\([^)]*(?:\)\s*)*)\s*{t.struct.fields[0].ident}\s*;[^\n]*', contract)
    t.scope = (0,len(contract)) if m is None else get_surrounding_scope(contract, m.start())

    #remove maps to wrap
    for f in t.struct.fields:
        contract = re.sub(f'(?P<ws>\n[ \t\r\f\v]*)(?P<pre>mapping\s*\([^)]*(?:\)\s*)*){f.ident}\s*;[^\n]*',
                          '', contract)

    #determine locations to insert new struct and map
    open_brac, close_brac = get_top_level_contract(contract, t.scope[0])

    struct_pattern = re.compile("\n[^/\n]*struct\s+(\w+)\s*{([^}]*)}")
    m = struct_pattern.search(contract, open_brac)
    struct_pos = m.start()

    wrap_map_pos = t.scope[0] + 1

    #create struct and map strings
    struct_str = '\n\t' + str(t.struct).replace('\n','\n\t') + '\n'

    start = contract.find('\n', t.scope[0])
    end = start+1
    while end < len(contract) and re.match('\s',contract[end]):
        end += 1
    new_map_name = f'wrapped{t.struct.name}'
    wrap_map_str = f'{contract[start:end]}mapping({t.key_type} => {t.struct.name}) {new_map_name};'

    #insert all at once (really lazy implementation)
    if struct_pos < wrap_map_pos:
        pos1,pos2 = struct_pos,wrap_map_pos
        str1,str2 = struct_str,wrap_map_str
    else:
        pos1,pos2 = wrap_map_pos,struct_pos
        str1,str2 = wrap_map_str,struct_str

    pre = contract[:pos1]
    mid = contract[pos1:pos2]
    end = contract[pos2:]

    def sub_wrap_field_access(m):
        ident = m.group('id')
        rest = m.group('rest')
        
        start = skip_ws(rest, 0)
        end = end_of_next_index_access(rest, start)
        index = rest[start:end]
        rest_of_line = rest[end:]
        
        rest_of_line = replace_arr_usages(ident, rest_of_line) # circular recursion - watch out
        
        return f'{new_map_name}{index}.{ident}{rest_of_line}'

    def replace_arr_usages(ident, s):
        return re.sub(f'(?<=\W)(?P<id>{ident})(?P<rest>\s*\[[^;]*)',
                      sub_wrap_field_access, s)

    for f in t.struct.fields:
        pre = replace_arr_usages(f.ident, pre)
        mid = replace_arr_usages(f.ident, mid)
        end = replace_arr_usages(f.ident, end)

    contract = pre + str1 + mid + str2 + end
    
    return contract


# - MERGE ----------------------------------------


#public
def merge(t, contract):
    '''Takes in a Merge object and source text,
and returns source text after merge.
This is a heuristic, and is not guaranteed to work.'''
    return contract


# - MAIN -----------------------------------------


def main():
    global verbose, o_structs, t_structs
    
    if len(sys.argv) == 1:
        print(readme)
        return 0
    if '-v' in sys.argv:
        verbose = True
        sys.argv.remove('-v')
    filename = sys.argv[1]
    
    fin = open(filename, 'r', encoding="utf-8")
    contract = fin.read()
    fin.close()
    
    fin = open('template.sol', 'r', encoding="utf-8")
    template = fin.read()
    fin.close()

    template, wraps = get_wraps_and_clean(template)

    o_structs = get_structs(contract)
    t_structs = get_structs(template)

    if verbose:
        print("\n === Original contract structs === \n")
        for s in o_structs:
            print(o_structs[s])
        print()
        print("\n === Template contract structs === \n")
        for s in t_structs:
            print(t_structs[s])
        print()

    transforms = get_transforms(contract, o_structs, t_structs)
    transforms['WRAP'] = wraps
    
    contractT = template #start off with edits from template

    if True: #verbose:
        print("\n === Transforms identified === \n")
        for transform_type in transforms:
            for t in transforms[transform_type]:
                print(t)
        print()

    if verbose:
        print("\n === Execution === \n")
    for transform_type in ['REORDER','UNWRAP','SPLIT','WRAP','MERGE']:
        for t in transforms[transform_type]:
            if verbose:
                print("Executing",t,"... ",end='')
            contractT = execute(t,contractT)
            if verbose:
                print("complete.")
    if verbose:
        print()

    filenameT = filename[:-4] + "T.sol"
    fout = open(filenameT, 'w', encoding="utf-8")
    fout.write(contractT)
    fout.close()

if __name__ == "__main__":
    main()

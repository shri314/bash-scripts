" Vim syntax file
"
" This file is a modified version of the existing vim C++
" syntax file in order to support C++11 language changes.
"
" Original Details
" ================
" Language:	C++
" Maintainer:	Ken Shan <ccshan@post.harvard.edu>
" Last Change:	2002 Jul 15

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Read the C syntax to start with
if version < 600
  so <sfile>:p:h/cpp11_cbase.vim
else
  runtime! syntax/cpp11_cbase.vim
  unlet b:current_syntax
endif

" C++ extentions
syn match cppCast		"\<\(const\|static\|dynamic\|reinterpret\)_cast\s*<"me=e-1
syn match cppCast		"\<\(const\|static\|dynamic\|reinterpret\)_cast\s*$"
syn match cppVirtualContext     /\<final\_s*[:{]/
syn match cppVirtualContext     /\<\(override\|final\|override\_s\+final\|final\_s\+override\)\ze\(\(\_s*=\_s*0\)\=\_s*[,;]\|\_s*\({\|\<try\_s*{\|=\_s*\(default\|delete\)\_s*;\)\)/
syn match cppRawString          /\%(u8\|u\|U\|L\)\=R"\([[:alnum:]_{}[\]#<>%:;.?*+\-/\^&|~!=,"']\{,16}\)(\_.\{-})\1"/ contains=cSpecial,cFormat,@Spell

syn keyword cppStatement	new delete this friend using static_assert noexcept
syn keyword cppAccess		public protected private
syn keyword cppType		inline virtual explicit export bool wchar_t char16_t char32_t decltype
syn keyword cppExceptions	throw try catch
syn keyword cppOperator		operator typeid alignof alignas co_await co_yield co_return
syn keyword cppOperator		and bitor or xor compl bitand and_eq or_eq xor_eq not not_eq
syn keyword cppVirtual          override final contained containedin=cppVirtualContext
syn keyword cppStorageClass	mutable constexpr thread_local
syn keyword cppStructure	class typename template namespace
syn keyword cppNumber		NPOS
syn keyword cppConstant		nullptr
syn keyword cppBoolean		true false
syn region  cppString           start=/\(u8\|u\|U\|L\)\="/ skip=/\\\\\|\\"/ end=/"/ contains=cSpecial,cFormat,@Spell

" The minimum and maximum operators in GNU C++
syn match cppMinMax "[<>]?"

" Default highlighting
if version >= 508 || !exists("did_cpp_syntax_inits")
  if version < 508
    let did_cpp_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
  HiLink cppAccess		cppStatement
  HiLink cppCast		cppStatement
  HiLink cppExceptions		Exception
  HiLink cppOperator		Operator
  HiLink cppStatement		Statement
  HiLink cppType		Type
  HiLink cppStorageClass	StorageClass
  HiLink cppStructure		Structure
  HiLink cppNumber		Number
  HiLink cppBoolean		Boolean
  HiLink cppConstant            Constant
  HiLink cppVirtual             Statement
  HiLink cppString              String
  HiLink cppRawString           String
  delcommand HiLink
endif

let b:current_syntax = "cpp"

" vim: ts=8

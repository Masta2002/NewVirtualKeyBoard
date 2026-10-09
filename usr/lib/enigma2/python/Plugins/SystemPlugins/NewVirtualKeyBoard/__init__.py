import os
from gettext import bindtextdomain, dgettext, find, gettext

from Components.Language import language
from Tools.Directories import resolveFilename, SCOPE_PLUGINS

# a fresh log per enigma2 start
try:
    os.remove('/tmp/VirtualKeyBoard.log')
except OSError:
    pass

# translations: the same gettext setup as other enigma2 plugins -
# locale/<lang>/LC_MESSAGES/NewVirtualKeyBoard.mo, following the enigma2
# language; only for a language without a plugin file the texts fall back to
# enigma2's own translation (a key cap kept as "Enter" in de.po must not
# become enigma2's "Eingeben")
PluginLanguageDomain = "NewVirtualKeyBoard"
PluginLanguagePath = "SystemPlugins/NewVirtualKeyBoard/locale"
_ownCatalogue = {}


def localeInit():
    bindtextdomain(PluginLanguageDomain, resolveFilename(SCOPE_PLUGINS, PluginLanguagePath))


def hasOwnCatalogue():
    # gettext.find() reads the same variables as dgettext (enigma2 sets
    # LANGUAGE); cached per setting
    key = tuple(os.environ.get(name) for name in ('LANGUAGE', 'LC_ALL', 'LC_MESSAGES', 'LANG'))
    if key not in _ownCatalogue:
        _ownCatalogue[key] = find(PluginLanguageDomain, resolveFilename(SCOPE_PLUGINS, PluginLanguagePath)) is not None
    return _ownCatalogue[key]


def _(txt):
    t = dgettext(PluginLanguageDomain, txt)
    if t == txt and not hasOwnCatalogue():
        t = gettext(txt)
    return t


localeInit()
language.addCallback(localeInit)

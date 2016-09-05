// Generated from src/Numbers.g4 by ANTLR 4.5.3
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.misc.*;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class NumbersLexer extends Lexer {
	static { RuntimeMetaData.checkVersion("4.5.3", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		NEWLINE=1, BIN_DIGIT=2, BINARY=3, DECIMAL=4, HEXADECIMAL=5;
	public static String[] modeNames = {
		"DEFAULT_MODE"
	};

	public static final String[] ruleNames = {
		"NEWLINE", "BIN_DIGIT", "BINARY", "DECIMAL", "HEXADECIMAL"
	};

	private static final String[] _LITERAL_NAMES = {
	};
	private static final String[] _SYMBOLIC_NAMES = {
		null, "NEWLINE", "BIN_DIGIT", "BINARY", "DECIMAL", "HEXADECIMAL"
	};
	public static final Vocabulary VOCABULARY = new VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);

	/**
	 * @deprecated Use {@link #VOCABULARY} instead.
	 */
	@Deprecated
	public static final String[] tokenNames;
	static {
		tokenNames = new String[_SYMBOLIC_NAMES.length];
		for (int i = 0; i < tokenNames.length; i++) {
			tokenNames[i] = VOCABULARY.getLiteralName(i);
			if (tokenNames[i] == null) {
				tokenNames[i] = VOCABULARY.getSymbolicName(i);
			}

			if (tokenNames[i] == null) {
				tokenNames[i] = "<INVALID>";
			}
		}
	}

	@Override
	@Deprecated
	public String[] getTokenNames() {
		return tokenNames;
	}

	@Override

	public Vocabulary getVocabulary() {
		return VOCABULARY;
	}


	public NumbersLexer(CharStream input) {
		super(input);
		_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@Override
	public String getGrammarFileName() { return "Numbers.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public String[] getModeNames() { return modeNames; }

	@Override
	public ATN getATN() { return _ATN; }

	public static final String _serializedATN =
		"\3\u0430\ud6d1\u8206\uad2d\u4417\uaef1\u8d80\uaadd\2\79\b\1\4\2\t\2\4"+
		"\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\3\2\6\2\17\n\2\r\2\16\2\20\3\3\3\3\3\4"+
		"\6\4\26\n\4\r\4\16\4\27\3\4\3\4\3\5\6\5\35\n\5\r\5\16\5\36\3\5\3\5\3\5"+
		"\5\5$\n\5\5\5&\n\5\3\5\5\5)\n\5\3\5\5\5,\n\5\3\5\6\5/\n\5\r\5\16\5\60"+
		"\3\6\3\6\3\6\6\6\66\n\6\r\6\16\6\67\2\2\7\3\3\5\4\7\5\t\6\13\7\3\2\t\5"+
		"\2\f\f\17\17\"\"\3\2\62\63\3\2\62;\4\2--//\3\2\62\62\4\2ZZzz\5\2\62;C"+
		"HchA\2\3\3\2\2\2\2\5\3\2\2\2\2\7\3\2\2\2\2\t\3\2\2\2\2\13\3\2\2\2\3\16"+
		"\3\2\2\2\5\22\3\2\2\2\7\25\3\2\2\2\t\34\3\2\2\2\13\62\3\2\2\2\r\17\t\2"+
		"\2\2\16\r\3\2\2\2\17\20\3\2\2\2\20\16\3\2\2\2\20\21\3\2\2\2\21\4\3\2\2"+
		"\2\22\23\t\3\2\2\23\6\3\2\2\2\24\26\5\5\3\2\25\24\3\2\2\2\26\27\3\2\2"+
		"\2\27\25\3\2\2\2\27\30\3\2\2\2\30\31\3\2\2\2\31\32\7d\2\2\32\b\3\2\2\2"+
		"\33\35\t\4\2\2\34\33\3\2\2\2\35\36\3\2\2\2\36\34\3\2\2\2\36\37\3\2\2\2"+
		"\37%\3\2\2\2 !\13\2\2\2!#\t\4\2\2\"$\t\4\2\2#\"\3\2\2\2#$\3\2\2\2$&\3"+
		"\2\2\2% \3\2\2\2%&\3\2\2\2&(\3\2\2\2\')\t\5\2\2(\'\3\2\2\2()\3\2\2\2)"+
		"+\3\2\2\2*,\7g\2\2+*\3\2\2\2+,\3\2\2\2,.\3\2\2\2-/\t\4\2\2.-\3\2\2\2/"+
		"\60\3\2\2\2\60.\3\2\2\2\60\61\3\2\2\2\61\n\3\2\2\2\62\63\t\6\2\2\63\65"+
		"\t\7\2\2\64\66\t\b\2\2\65\64\3\2\2\2\66\67\3\2\2\2\67\65\3\2\2\2\678\3"+
		"\2\2\28\f\3\2\2\2\f\2\20\27\36#%(+\60\67\2";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}
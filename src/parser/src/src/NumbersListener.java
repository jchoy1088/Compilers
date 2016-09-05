// Generated from src/Numbers.g4 by ANTLR 4.5.3
import org.antlr.v4.runtime.tree.ParseTreeListener;

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link NumbersParser}.
 */
public interface NumbersListener extends ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link NumbersParser#number}.
	 * @param ctx the parse tree
	 */
	void enterNumber(NumbersParser.NumberContext ctx);
	/**
	 * Exit a parse tree produced by {@link NumbersParser#number}.
	 * @param ctx the parse tree
	 */
	void exitNumber(NumbersParser.NumberContext ctx);
}
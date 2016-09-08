import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Scanner;
import java.util.Stack;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.Token;

public class Numbers {
	public static void main(String[] args) {
		NumbersLexer lexer = null;
		Token tk;
		FileInputStream fis = null;
		File file = null;
		Stack<Double> stk;
		Scanner scn = new Scanner(System.in);
		try {
			String tokenscn;
			StringBuilder strB = new StringBuilder();
			while (scn.hasNext() && !(tokenscn = scn.next()).equalsIgnoreCase("")) {
				strB.append(tokenscn + "\n");
			}
			lexer = new NumbersLexer(new ANTLRInputStream(strB.toString()));
			stk = new Stack<Double>();
		} catch (Exception e) {
			System.out.println("Erro:" + e);
			System.exit(1);
			return;
		}
		do {
			tk = lexer.nextToken();
			switch (tk.getType()) {
			case NumbersLexer.BIN_NUM:
				System.out.println("INTEIRO BINARIO: " + tk.getText());
				break;
			case NumbersLexer.INT_NUM:
				System.out.println("INTEIRO DECIMAL: " + tk.getText());
				break;
			case NumbersLexer.DEC_NUM:
				System.out.println("REAL DECIMAL: " + tk.getText());
				break;
			case NumbersLexer.HEX_NUM:
				System.out.println("INTEIRO HEXADECIMAL: " + tk.getText());
				break;
			}
		} while (tk != null && tk.getType() != Token.EOF);

	}
}
import java.io.File;
import java.io.FileInputStream;
import java.util.Stack;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.Token;

import parser.src.NumbersLexer;

public class Numbers {
	public static void main(String[] args) {
		NumbersLexer lexer;
		Token tk;
		FileInputStream fis = null;
		File file = null;
		Stack<Double> stk;
		try {
			file = new File("/home/jchoy/arq_testes/arquivo.txt");
			fis = new FileInputStream(file);
			lexer = new NumbersLexer(new ANTLRInputStream(fis));
			stk = new Stack<Double>();
		} catch (Exception e) {
			System.out.println("Erro:" + e);
			System.exit(1);
			return;
		}
		do {
			tk = lexer.nextToken();
			Double num = 0.0;
			Double topo1 = 0.0;
			Double topo2 = 0.0;
			switch (tk.getType()) {
			case NumbersLexer.BINARY:
				System.out.println("INTEIRO BINARIO: " + tk.getText());
				num = Double.parseDouble(tk.getText());
				break;
			case NumbersLexer.BIN_DIGIT:
				System.out.println("INTEIRO DECIMAL: " + tk.getText());
				num = Double.parseDouble(tk.getText());
				break;
			case NumbersLexer.DECIMAL:
				System.out.println("REAL DECIMAL: " + tk.getText());
				num = Double.parseDouble(tk.getText());
				break;
			case NumbersLexer.HEXADECIMAL:
				System.out.println("INTEIRO HEXADECIMAL: " + tk.getText());
				num = Double.parseDouble(tk.getText());
				break;
			case NumbersLexer.PLUS:
				System.out.println("Adicionando");
				topo1 = stk.lastElement();
				stk.pop();
				topo2 = stk.lastElement();
				stk.pop();
				num = topo2 + topo1;
				break;
			case NumbersLexer.MULTIP:
				System.out.println("Multiplicando");
				topo1 = stk.lastElement();
				stk.pop();
				topo2 = stk.lastElement();
				stk.pop();
				num = topo2 + topo1;
				break;
			case NumbersLexer.MINUS:
				System.out.println("Disminuindo");
				topo1 = stk.lastElement();
				stk.pop();
				topo2 = stk.lastElement();
				stk.pop();
				num = topo2 - topo1;
				break;
			case NumbersLexer.DIVIS:
				System.out.println("Diviendo");
				topo1 = stk.lastElement();
				stk.pop();
				topo2 = stk.lastElement();
				stk.pop();
				num = topo2 / topo1;
				break;
			case NumbersLexer.POTEN:
				System.out.println("Potencia");
				topo1 = stk.lastElement();
				stk.pop();
				topo2 = stk.lastElement();
				stk.pop();
				num = Math.pow(topo2, topo1);
				break;
			}
			stk.add(num);
		} while (tk != null && tk.getType() != Token.EOF);

	}
}
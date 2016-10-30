import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Scanner;
import java.util.Stack;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.Token;

public class Numbers {
	public static void main(String[] args) {
		FreeLinguagemLexer lexer = null;
		Token tk;
		FileInputStream fis = null;
		File file = null;
		Stack<Double> stk;
		try {
			ClassLoader classLoader = Numbers.class.getClassLoader();
			System.out.println(classLoader.getResource("inputs.txt") + "--------");
			file = new File(classLoader.getResource("inputs.txt").getFile());
			fis = new FileInputStream(file);
			lexer = new FreeLinguagemLexer(new ANTLRInputStream(fis));
			stk = new Stack<Double>();
		} catch (Exception e) {
			System.out.println("Erro:" + e);
			System.exit(1);
			return;
		}
		do {
			tk = lexer.nextToken();
			double num = 0.0;
			Double topo1 = 0.0, topo2 = 0.0;
			switch (tk.getType()) {
			case FreeLinguagemLexer.BINARY:
				System.out.println(tk.getType() + " 1");
				num = convertNumbers(tk.getText(), 0);
				stk.add(num);
				break;
			case FreeLinguagemLexer.DECIMAL:
				System.out.println(tk.getType() + " 2");
				num = Double.parseDouble(tk.getText());
				stk.add(num);
				break;
			case FreeLinguagemLexer.FLOAT:
				System.out.println(tk.getType() + " 3");
				num = Double.parseDouble(tk.getText());
				stk.add(num);
				break;
			case FreeLinguagemLexer.HEXADECIMAL:
				System.out.println(tk.getType() + " 4");
				num = convertNumbers(tk.getText(), 1);
				stk.add(num);
				break;
			case FreeLinguagemLexer.TOK_PLUS_OR_MINUS:
				char op = tk.getText().charAt(0);
				if (stk.size() > 1) {
					if (op == '*')
						num = operacaoTokens(stk, 0);
					else if (op == '+')
						num = operacaoTokens(stk, 1);
					else if (op == '/')
						num = operacaoTokens(stk, 2);
					else if (op == '-')
						num = operacaoTokens(stk, 3);
					else
						num = operacaoTokens(stk, 4);
					stk.add(num);
				}
				break;
			/*
			 * case FreeLinguagemLexer.STATUS: for (int i = 0; i < stk.size();
			 * i++) { System.out.println(i + " - " + stk.get(i)); } break; case
			 * FreeLinguagemLexer.CLEAR: stk.clear(); break;
			 */
			}
		} while (tk != null && tk.getType() != Token.EOF);

	}

	private static double convertNumbers(String number, int tipo) {
		if (!number.isEmpty() || !number.equals("")) {
			if (tipo == 0)
				return Integer.parseInt(number.substring(0, number.length() - 1), 2);
			else
				return Integer.parseInt(number.substring(2), 16);
		}
		return 0;
	}

	private static double operacaoTokens(Stack<Double> stk, int tipoOp) {
		double topo1 = stk.pop(), topo2 = stk.pop();
		if (tipoOp == 0) {
			return topo2 * topo1;
		} else if (tipoOp == 1) {
			return topo2 + topo1;
		} else if (tipoOp == 2) {
			return topo2 / topo1;
		} else if (tipoOp == 3) {
			return topo2 - topo1;
		} else {
			return Math.pow(topo2, topo1);
		}
	}
}

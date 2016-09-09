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
			double num = 0.0;
			Double topo1 = 0.0, topo2 = 0.0;
			switch (tk.getType()) {
			case NumbersLexer.BIN_NUM:
				num = convertNumbers(tk.getText(), 0);
				stk.add(num);
				break;
			case NumbersLexer.INT_NUM:
				num = Double.parseDouble(tk.getText());
				stk.add(num);
				break;
			case NumbersLexer.DEC_NUM:
				num = Double.parseDouble(tk.getText());
				stk.add(num);
				break;
			case NumbersLexer.HEX_NUM:
				num = convertNumbers(tk.getText(), 1);
				stk.add(num);
				break;
			case NumbersLexer.SIGNO:
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
			case NumbersLexer.STATUS:
				for (int i = 0; i < stk.size(); i++) {
					System.out.println(i + " - " + stk.get(i));
				}
				break;
			case NumbersLexer.CLEAR:
				stk.clear();
				break;
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
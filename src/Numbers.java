import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.Token;

// class ANTLRInputStream , Token

public class Numbers {
	public static void main(String[] args) {
		NumbersLexer lexer;
		Token tk;

		// Cria instancia do lexer criado pelo ANTLR

		try {
			lexer = new NumbersLexer(new ANTLRInputStream(System.in));
		} catch (Exception e) {
			// Pikachu!
			/* teste */
			System.out.println("Erro:" + e);
			System.exit(1);
			return;
		}

		// Le da entrada padrao ateh chegar digitar CTRL-D (Linux/Mac)
		// ou CTRL-Z (Windows)

		do {
			tk = lexer.nextToken();
			switch (tk.getType()) {
			case NumbersLexer.BINARY:
				System.out.println("bin: " + tk.getText());
				break;

			/*
			 * case NumbersLexer.DECIMAL: System.out.println("dec: " +
			 * tk.getText()); break;
			 * 
			 * ...
			 * 
			 */
			}
		} while (tk != null && tk.getType() != Token.EOF);

	}
}

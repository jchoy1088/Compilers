import java.io.FileInputStream;

import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;

// class ANTLRInputStream , Token
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;

public class Interpreter {

	public static void main(String args[]) {

		// ou recebe como argumento, depende de como preferir executar
		JFileChooser chooser = new JFileChooser();
		chooser.setFileFilter(new FileNameExtensionFilter("Text File", "txt"));
		int retval = chooser.showOpenDialog(null);
		if (retval != JFileChooser.APPROVE_OPTION)
			return;
		try {
			FileInputStream fin = new FileInputStream(chooser.getSelectedFile());
			//FileInputStream fin = new FileInputStream("/home/jchoy/ws/ws_compiladores/CompiladoresE1/resources/inputs.txt");
			FreeLinguagemLexer lexer = new FreeLinguagemLexer(new ANTLRInputStream(fin));
			CommonTokenStream tokens = new CommonTokenStream(lexer);
			FreeLinguagemParser parser = new FreeLinguagemParser(tokens);
			parser.interpreter(); // Comecando dessa regra , poderia trocar
			// por .funcbody ou .metaexpr
		} catch (Exception e) {
			// Pikachu!
			System.out.println("Erro:" + e);
			return;
		}
	}
}
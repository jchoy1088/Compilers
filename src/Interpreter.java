import org.antlr.v4.runtime.*; // class ANTLRInputStream , Token

import java.io.*;
import javax.swing.JFileChooser;
import javax.swing.filechooser.*;


public class Interpreter{

	public static void main(String args[]){
    	FreeLinguagemLexer lexer;
    	FreeLinguagemParser parser;

        JFileChooser chooser = new JFileChooser();
        FileNameExtensionFilter filter = new FileNameExtensionFilter("Text File", "txt");
        chooser.setFileFilter(filter);
        int retval = chooser.showOpenDialog(null);
        if (retval != JFileChooser.APPROVE_OPTION)
            return;

        File input = chooser.getSelectedFile();

        try {
            FileInputStream fin = new FileInputStream(input);
            lexer = new FreeLinguagemLexer(new ANTLRInputStream(fin));
            CommonTokenStream tokens = new CommonTokenStream(lexer);
            parser = new FreeLinguagemParser(tokens);
            parser.interprete(); // Comecando dessa regra , poderia trocar por .funcbody ou .metaexpr
        } catch (Exception e) {
            // Pikachu!
            System.out.println("Erro:" + e);
            System.exit(1);
            return;
        }
	}
}
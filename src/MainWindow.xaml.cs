using System;
using System.Windows;
using System.Windows.Controls;
using Mommosoft.ExpertSystem;

namespace SystemDoradczy
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private readonly Mommosoft.ExpertSystem.Environment _theEnv = new Mommosoft.ExpertSystem.Environment();
        public MainWindow()
        {
            InitializeComponent();
            _theEnv.AddRouter(new DebugRouter());
            _theEnv.Clear();
            _theEnv.Load("baza.clp");
            _theEnv.Reset();
            NextUiState();
        }

        private void NextUiState()
        {
            NextBtn.Visibility = Visibility.Hidden;
            PrevBtn.Visibility = Visibility.Hidden;
            AnswersPanel.Children.Clear();
            _theEnv.Run();
            
            var evalStr = "(find-all-facts ((?f state-list)) TRUE)";
            using (var allFacts = (FactAddressValue)((MultifieldValue)_theEnv.Eval(evalStr))[0])
            {
                string currentId = allFacts.GetFactSlot("current").ToString();
                evalStr = "(find-all-facts ((?f UI-state)) " +
                               "(eq ?f:id " + currentId + "))";
            }

            using (var evalFact = (FactAddressValue)((MultifieldValue)_theEnv.Eval(evalStr))[0])
            {
                string state = evalFact.GetFactSlot("state").ToString();
                switch (state)
                {
                    case "initial":
                        NextBtn.Content = "Dalej";
                        NextBtn.Visibility = Visibility.Visible;
                        break;
                    case "final":
                        NextBtn.Content = "Reset";
                        NextBtn.Visibility = Visibility.Visible;
                        break;
                    default:
                        NextBtn.Content = "Dalej";
                        NextBtn.Visibility = Visibility.Visible;
                        PrevBtn.Content = "Powrót";
                        PrevBtn.Visibility = Visibility.Visible;
                        break;

                }

                using (var validAnswers = (MultifieldValue)evalFact.GetFactSlot("valid-answers"))
                {
                    var selected = evalFact.GetFactSlot("response").ToString();
                    for (int i = 0; i < validAnswers.Count; i++)
                    {
                        var rb = new RadioButton { Margin = new Thickness(3), Content = validAnswers[i].ToString().Replace("_"," "), GroupName = "answers", IsChecked = selected == (validAnswers[i]).ToString() };
                        AnswersPanel.Children.Add(rb);
                    }
                }

                QuestionLbl.Text = Messages.ResourceManager.GetString((SymbolValue)evalFact.GetFactSlot("display"));
            }

            
        }

        private string GetAnswer()
        {

            foreach (var child in AnswersPanel.Children)
            {
                var radio = child as RadioButton;
                if (radio == null) continue;
                if (radio.IsChecked.HasValue && radio.IsChecked.Value)
                    return radio.Content.ToString().Replace(" ","_");

            }
            return null;
        }

        private void NextBtn_OnClick(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            if(button == null) return;
            const string evalStr = "(find-all-facts ((?f state-list)) TRUE)";
            using (var f = (FactAddressValue) ((MultifieldValue) _theEnv.Eval(evalStr))[0])
            {
                string currentId = f.GetFactSlot("current").ToString();
                switch (button.Content.ToString())
                {
                    case "Dalej":
                        if (AnswersPanel.Children.Count == 0)
                        {
                            _theEnv.AssertString("(next " + currentId + ")");
                        }
                        else
                        {
                            var t = $"(next {currentId} {GetAnswer()})";
                            _theEnv.AssertString(t);
                        }
                        NextUiState();
                        break;
                    case "Reset":
                        _theEnv.Reset();
                        NextUiState();
                        break;
                    case "Powrót":
                        _theEnv.AssertString("(prev " + currentId + ")");
                        NextUiState();
                        break;
                }

            }

        }

    }
}

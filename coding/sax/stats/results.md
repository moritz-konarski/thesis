# paa_segments

- is_sax ~ recall is significant for only considering individual sax, but not
significant, even negative when considering a combination of both sax
    - tested for different types of paa counts
    - 18 seems to be a good mix of recall and dimensionality reduction
    - for alphabet sizes, we get the same that single sax is worse than msax;
    5 or up seems to give very similar results; for larger alph, the
    combination sax seems to become more accurate, while msax levels out; there
    is not significant correlation though;

# Notes

- make hypothesis clear that I assume to compare Msax to 1 SAX because they
both yield one SAX word -> hypothesis is that MSAX is better here
- also compare it so simply using SAX twice and combining the results: at that
point, 2 SAX things are slightly better

=> try this with the incart database that has 12 leads and see which method
works better

=> important: eliminate the subsequence length from the calculations, delete
the old raw data, and then rerun the whole thing with more segment length and
ks, but without different subsequence lengths

1. compare across all parameters
2. concat the SAXs into one to be able to compare both of them
3. find top 5 optimal recall parameters across all 48 ECGs for SAX and  MSAX
   each
4. investigate which one is better and what that means
5. test the best parameters on ST-T data base and see if the results are
   similar or not
6. analyze the subsequence data set first because the other one can be cut down
   to match these parameters, while I cannot extend it 

# MetadataUsesCessdaAccessRights

## High-level description

This class provides a utility for checking whether a **CESSDA data catalogue record**
(DDI 2.5 metadata delivered via the CESSDA OAI-PMH endpoint) contains an Access Rights term
that belongs to the **approved Access Rights terms** as defined by the CESSDA controlled vocabulary.

The detection strategy:

1. **Fetches approved Access Rights terms from a CESSDA vocabulary**
   - Queries the CESSDA Access Rights vocabulary API for current terms list.
   - Caches the approved terms (Open, Restricted) to minimize network calls.
2. **Examines DDI identifier elements**
   - Parses the `typeOfAccess` element from the DDI record.
   - Compares value against the list of approved Data Access terms.

## Primary usage

Call `containsApprovedCessdaAccessRights(String url)` with a CESSDA catalogue *detail page URL*. The method will:

1. Extract the record identifier from the provided URL (expects a `/detail/{id}` path segment).
2. Fetch the record via the configured OAI-PMH **GetRecord** endpoint (`metadataPrefix=oai_ddi25`).
3. Parse the returned XML and isolate the DDI `<codeBook>` element for further XPath evaluation.
4. Evaluate the configured XPath expression to obtain DDI `<typeOfAccess>` element from the study citation.

## Return values

- **`"pass"`** — Uses an approved Access Rights term (e.g., Open or Restricted).
- **`"fail"`** — Does not use an approved Data Access term, or no `<typeOfAccess>` element exist.
- **`"indeterminate"`** — An error or exception occurred that prevents a definitive determination
(e.g., network error, XML parse failure, missing codeBook element).

## Networking and timeouts

- Uses a shared [`java.net.http.HttpClient`](https://docs.oracle.com/en/java/javase/21/docs/api/java.net.http/java/net/http/HttpClient.html) configured with a **10-second connect timeout** and automatic redirect following.
- OAI-PMH XML fetch has a **30-second request timeout**.
- CESSDA vocabulary API calls use a **20-second timeout**.
- HTTP requests include `Accept` and `User-Agent` headers to influence server responses.

## XML processing

- Uses a namespace-aware [`DocumentBuilderFactory`](https://docs.oracle.com/en/java/javase/21/docs/api/java.xml/javax/xml/parsers/DocumentBuilderFactory.html)  
  and `XPath` with a simple [`NamespaceContext`](https://docs.oracle.com/en/java/javase/21/docs/api/java.xml/javax/xml/namespace/NamespaceContext.html)  
  that maps the `ddi` prefix to the DDI 2.5 namespace.
- Only the first top-level `//ddi:codeBook` node is extracted and used to build a minimal XML document.
- The DDI identifier search XPath is configurable via a class constant:  
  `//ddi:codeBook/ddi:stdyDscr/ddi:citation/ddi:titlStmt/ddi:IDNo`

## CESSDA vocabulary integration

- Queries the **CESSDA Access Rights vocabulary** (version 1.0.0) in JSON format.
- Parses the vocabulary structure to extract Access Rights terms from the `concepts` array.
- Expected JSON structure:
  - Top-level `"versions"` array
  - Each version containing a `"concepts"` array
  - Each concept with a `"title"` field containing the Access Rights term
- Terms are normalized by trimming whitespace and stored in an **unmodifiable Set**.
- If the vocabulary fetch fails or returns no valid terms, falls back to a default set:  
  `{"Open", "Restricted"}`

## Caching and synchronization

- The approved Data Access terms are cached in a **volatile static Set** after first fetch.
- Cache initialization uses **double-checked locking** with class-level synchronization  
  to prevent redundant API calls during concurrent access.
- The cache is populated once per JVM instance and reused across all method invocations.

## Error handling and logging

- Errors while fetching or parsing OAI-PMH or vocabulary API responses are logged at **SEVERE** level.
- These typically cause the method to return `"indeterminate"`.
- Non-200 HTTP responses trigger fallback to default Data Access terms with appropriate logging.
- XML parse failures include a truncated preview (first 500 bytes) of the response body for debugging.
- All log messages escape `%` characters to prevent format string interpretation issues.

## Input expectations and validation

- Catalogue URL must include `/detail/{identifier}`.  
  If missing or empty, an `IllegalArgumentException` is thrown.
- Query parameters (if present) are stripped before identifier extraction.
- The record identifier must be non-empty after extraction.

## Main entry point and exit codes

- A `main()` method is provided for CLI usage.  
  It accepts a single URL argument and prints/logs the final result.
- JVM exits with:
  - Code **0** → when result is `"pass"`
  - Code **1** → otherwise

## Constants and customization

- Behaviour-determining constants:
  - DDI namespace (`ddi:codebook:2_5`)
  - OAI-PMH base URL
  - CESSDA vocabulary API URL
  - XPath for identifier elements
  - Result token strings
- Adjusting these constants allows adapting the tool for different endpoints or DDI variants.

## Thread safety

- Instances are thread-safe after initial cache population.
- Uses thread-safe `HttpClient` and synchronized cache initialization.
- Concurrent invocations during initial cache population are handled via double-checked locking;  
  only one thread will fetch from the API.
- The `InterruptedException` is properly handled by restoring thread interrupt status.

## Notes and limitations

- Assumes the OAI-PMH provider returns valid DDI 2.5 XML containing a `<codeBook>` node.
- Access Rights term matching is case-sensitive and requires exact matches against vocabulary entries.
- Uses Jackson `ObjectMapper` for JSON parsing; unexpected vocabulary structure results  
  in empty terms list and fallback to defaults.
- Logging level is set to `INFO` by default; can be adjusted via the `Logger` instance.
